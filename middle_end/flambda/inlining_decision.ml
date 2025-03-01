(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*                       Pierre Chambart, travlangPro                        *)
(*           Mark Shinwell and Leo White, Jane Street Europe              *)
(*                                                                        *)
(*   Copyright 2013--2016 travlangPro SAS                                    *)
(*   Copyright 2014--2016 Jane Street Group LLC                           *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

[@@@travlang.warning "+a-4-9-30-40-41-42-66"]
open! Int_replace_polymorphic_compare

module A = Simple_value_approx
module E = Inline_and_simplify_aux.Env
module R = Inline_and_simplify_aux.Result
module W = Inlining_cost.Whether_sufficient_benefit
module T = Inlining_cost.Threshold
module S = Inlining_stats_types
module D = S.Decision

let get_function_body (function_decl : A.function_declaration) =
  match function_decl.function_body with
  | None -> assert false
  | Some function_body -> function_body

type ('a, 'b) inlining_result =
  | Changed of (Flambda.t * R.t) * 'a
  | Original of 'b

type 'b good_idea =
  | Try_it
  | Don't_try_it of 'b

let inline env r ~lhs_of_application
    ~closure_id_being_applied
    ~(function_decl : A.function_declaration)
    ~(function_body : A.function_body)
    ~value_set_of_closures ~only_use_of_function ~original ~recursive
    ~(args : Variable.t list) ~size_from_approximation ~dbg ~simplify
    ~(inline_requested : Lambda.inline_attribute)
    ~(specialise_requested : Lambda.specialise_attribute)
    ~fun_vars ~set_of_closures_origin
    ~self_call ~fun_cost ~inlining_threshold =
  let toplevel = E.at_toplevel env in
  let branch_depth = E.branch_depth env in
  let unrolling, always_inline, never_inline, env =
    let unrolling = E.actively_unrolling env set_of_closures_origin in
    match unrolling with
    | Some count ->
      if count > 0 then
        let env = E.continue_actively_unrolling env set_of_closures_origin in
        true, true, false, env
      else false, false, true, env
    | None -> begin
        let inline_annotation =
          (* Merge call site annotation and function annotation.
             The call site annotation takes precedence *)
          match (inline_requested : Lambda.inline_attribute) with
          | Always_inline | Hint_inline | Never_inline | Unroll _ ->
              inline_requested
          | Default_inline -> function_body.inline
        in
        match inline_annotation with
        | Always_inline | Hint_inline -> false, true, false, env
        | Never_inline -> false, false, true, env
        | Default_inline -> false, false, false, env
        | Unroll count ->
          if count > 0 then
            let env =
              E.start_actively_unrolling
                env set_of_closures_origin (count - 1)
            in
            true, true, false, env
          else false, false, true, env
      end
  in
  let remaining_inlining_threshold : Inlining_cost.Threshold.t =
    if always_inline then inlining_threshold
    else Lazy.force fun_cost
  in
  let try_inlining =
    if unrolling then
      Try_it
    else if self_call then
      Don't_try_it S.Not_inlined.Self_call
    else if not (E.inlining_allowed env function_decl.closure_origin) then
      Don't_try_it S.Not_inlined.Unrolling_depth_exceeded
    else if only_use_of_function || always_inline then
      Try_it
    else if never_inline then
      Don't_try_it S.Not_inlined.Annotation
    else if not (E.unrolling_allowed env set_of_closures_origin)
         && (Lazy.force recursive) then
      Don't_try_it S.Not_inlined.Unrolling_depth_exceeded
    else if T.equal remaining_inlining_threshold T.Never_inline then
      let threshold =
        match inlining_threshold with
        | T.Never_inline -> assert false
        | T.Can_inline_if_no_larger_than threshold -> threshold
      in
      Don't_try_it (S.Not_inlined.Above_threshold threshold)
    else if not (toplevel && branch_depth = 0)
         && A.all_not_useful (E.find_list_exn env args) then
      (* When all of the arguments to the function being inlined are unknown,
         then we cannot materially simplify the function.  As such, we know
         what the benefit of inlining it would be: just removing the call.
         In this case we may be able to prove the function cannot be inlined
         without traversing its body.
         Note that if the function is sufficiently small, we still have to call
         [simplify], because the body needs freshening before substitution.
      *)
      (* CR-someday mshinwell: (from GPR#8): pchambart writes:

          We may need to think a bit about that. I can't see a lot of
          meaningful examples right now, but there are some cases where some
          optimization can happen even if we don't know anything about the
          shape of the arguments.

          For instance

          let f x y = x

          let g x =
            let y = (x,x) in
            f x y
          let f x y =
            if x = y then ... else ...

          let g x = f x x
      *)
      match size_from_approximation with
      | Some body_size ->
        let wsb =
          let benefit = Inlining_cost.Benefit.zero in
          let benefit = Inlining_cost.Benefit.remove_call benefit in
          let benefit =
            Variable.Set.fold (fun v acc ->
                try
                  let t =
                    Var_within_closure.Map.find (Var_within_closure.wrap v)
                      value_set_of_closures.A.bound_vars
                  in
                  match t.A.var with
                  | Some v ->
                    if (E.mem env v) then Inlining_cost.Benefit.remove_prim acc
                    else acc
                  | None -> acc
                with Not_found -> acc)
              function_body.free_variables benefit
          in
          W.create_estimate
            ~original_size:Inlining_cost.direct_call_size
            ~new_size:body_size
            ~toplevel:(E.at_toplevel env)
            ~branch_depth:(E.branch_depth env)
            ~lifting:function_body.A.is_a_functor
            ~round:(E.round env)
            ~benefit
        in
        if (not (W.evaluate wsb)) then begin
          Don't_try_it
            (S.Not_inlined.Without_subfunctions wsb)
        end else Try_it
      | None ->
        (* The function is definitely too large to inline given that we don't
           have any approximations for its arguments.  Further, the body
           should already have been simplified (inside its declaration), so
           we also expect no gain from the code below that permits inlining
           inside the body. *)
        Don't_try_it S.Not_inlined.No_useful_approximations
    else begin
      (* There are useful approximations, so we should simplify. *)
      Try_it
    end
  in
  match try_inlining with
  | Don't_try_it decision -> Original decision
  | Try_it ->
    let r =
      R.set_inlining_threshold r (Some remaining_inlining_threshold)
    in
    let body, r_inlined =
      (* First we construct the code that would result from copying the body of
         the function, without doing any further inlining upon it, to the call
         site. *)
      Inlining_transforms.inline_by_copying_function_body ~env
        ~r:(R.reset_benefit r) ~lhs_of_application
        ~closure_id_being_applied ~specialise_requested ~inline_requested
        ~function_decl ~function_body ~fun_vars ~args ~dbg ~simplify
    in
    let num_direct_applications_seen =
      (R.num_direct_applications r_inlined) - (R.num_direct_applications r)
    in
    assert (num_direct_applications_seen >= 0);
    let keep_inlined_version decision =
      (* Inlining the body of the function was sufficiently beneficial that we
         will keep it, replacing the call site.  We continue by allowing
         further inlining within the inlined copy of the body. *)
      let r_inlined =
        (* The meaning of requesting inlining is that the user ensure
           that the function has a benefit of at least its size. It is not
           added to the benefit exposed by the inlining because the user should
           have taken that into account before annotating the function. *)
        if always_inline then
          R.map_benefit r_inlined
            (Inlining_cost.Benefit.max ~round:(E.round env)
               Inlining_cost.Benefit.(requested_inline ~size_of:body zero))
        else r_inlined
      in
      let r =
        R.map_benefit r_inlined (Inlining_cost.Benefit.(+) (R.benefit r))
      in
      let env = E.note_entering_inlined env in
      let env =
        (* We decrement the unrolling count even if the function is not
           recursive to avoid having to check whether or not it is recursive *)
        E.inside_unrolled_function env set_of_closures_origin
      in
      let env = E.inside_inlined_function env function_decl.closure_origin in
      let env =
        if E.inlining_level env = 0
           (* If the function was considered for inlining without considering
              its sub-functions, and it is not below another inlining choice,
              then we are certain that this code will be kept. *)
        then env
        else E.inlining_level_up env
      in
      Changed ((simplify env r body), decision)
    in
    if always_inline then
      keep_inlined_version S.Inlined.Annotation
    else if only_use_of_function then
      keep_inlined_version S.Inlined.Decl_local_to_application
    else begin
      let wsb =
        W.create ~original body
          ~toplevel:(E.at_toplevel env)
          ~branch_depth:(E.branch_depth env)
          ~lifting:function_body.is_a_functor
          ~round:(E.round env)
          ~benefit:(R.benefit r_inlined)
      in
      if W.evaluate wsb then
        keep_inlined_version (S.Inlined.Without_subfunctions wsb)
      else if num_direct_applications_seen < 1 then begin
      (* Inlining the body of the function did not appear sufficiently
         beneficial; however, it may become so if we inline within the body
         first.  We try that next, unless it is known that there were
         no direct applications in the simplified body computed above, meaning
         no opportunities for inlining. *)
        Original (S.Not_inlined.Without_subfunctions wsb)
      end else begin
        let env = E.inlining_level_up env in
        let env = E.note_entering_inlined env in
        let env =
          (* We decrement the unrolling count even if the function is recursive
             to avoid having to check whether or not it is recursive *)
          E.inside_unrolled_function env set_of_closures_origin
        in
        let body, r_inlined = simplify env r_inlined body in
        let wsb_with_subfunctions =
          W.create ~original body
            ~toplevel:(E.at_toplevel env)
            ~branch_depth:(E.branch_depth env)
            ~lifting:function_body.is_a_functor
            ~round:(E.round env)
            ~benefit:(R.benefit r_inlined)
        in
        if W.evaluate wsb_with_subfunctions then begin
          let res =
            (body, R.map_benefit r_inlined
                     (Inlining_cost.Benefit.(+) (R.benefit r)))
          in
          let decision =
            S.Inlined.With_subfunctions (wsb, wsb_with_subfunctions)
          in
          Changed (res, decision)
        end
        else begin
          (* r_inlined contains an approximation that may be invalid for the
             untransformed expression: it may reference functions that only
             exists if the body of the function is in fact inlined.
             If the function approximation contained an approximation that
             does not depend on the actual values of its arguments, it
             could be returned instead of [A.value_unknown]. *)
          let decision =
            S.Not_inlined.With_subfunctions (wsb, wsb_with_subfunctions)
          in
          Original decision
        end
      end
    end

let specialise env r ~lhs_of_application
      ~(function_decls : A.function_declarations)
      ~(function_decl : A.function_declaration)
      ~closure_id_being_applied
      ~(value_set_of_closures : A.value_set_of_closures)
      ~args ~args_approxs ~dbg ~simplify ~original ~recursive ~self_call
      ~inlining_threshold ~fun_cost
      ~inline_requested ~specialise_requested =
  let invariant_params = value_set_of_closures.invariant_params in
  let free_vars = value_set_of_closures.free_vars in
  let has_no_useful_approxes =
    lazy
      (List.for_all2
         (fun id approx ->
            not ((A.useful approx)
                 && Variable.Map.mem id (Lazy.force invariant_params)))
         (Parameter.List.vars function_decl.params) args_approxs)
  in
  let always_specialise, never_specialise =
    (* Merge call site annotation and function annotation.
       The call site annotation takes precedence *)
    match (specialise_requested : Lambda.specialise_attribute) with
    | Always_specialise -> true, false
    | Never_specialise -> false, true
    | Default_specialise -> begin
        match function_decl.function_body with
        | None -> false, true
        | Some { specialise } ->
          match (specialise : Lambda.specialise_attribute) with
          | Always_specialise -> true, false
          | Never_specialise -> false, true
          | Default_specialise -> false, false
      end
  in
  let remaining_inlining_threshold : Inlining_cost.Threshold.t =
    if always_specialise then inlining_threshold
    else Lazy.force fun_cost
  in
  let try_specialising =
    (* Try specialising if the function:
       - is recursive; and
       - is closed (it and all other members of the set of closures on which
         it depends); and
       - has useful approximations for some invariant parameters. *)
    if function_decls.is_classic_mode then
      Don't_try_it S.Not_specialised.Classic_mode
    else if self_call then
      Don't_try_it S.Not_specialised.Self_call
    else if always_specialise && not (Lazy.force has_no_useful_approxes) then
      Try_it
    else if never_specialise then
      Don't_try_it S.Not_specialised.Annotation
    else if T.equal remaining_inlining_threshold T.Never_inline then
      let threshold =
        match inlining_threshold with
        | T.Never_inline -> assert false
        | T.Can_inline_if_no_larger_than threshold -> threshold
      in
      Don't_try_it (S.Not_specialised.Above_threshold threshold)
    else if not (Variable.Map.is_empty free_vars) then
      Don't_try_it S.Not_specialised.Not_closed
    else if not (Lazy.force recursive) then
      Don't_try_it S.Not_specialised.Not_recursive
    else if Variable.Map.is_empty (Lazy.force invariant_params) then
      Don't_try_it S.Not_specialised.No_invariant_parameters
    else if Lazy.force has_no_useful_approxes then
      Don't_try_it S.Not_specialised.No_useful_approximations
    else Try_it
  in
  match try_specialising with
  | Don't_try_it decision -> Original decision
  | Try_it -> begin
      let r =
        R.set_inlining_threshold r (Some remaining_inlining_threshold)
      in
      let copied_function_declaration =
        Inlining_transforms.inline_by_copying_function_declaration ~env
          ~r:(R.reset_benefit r) ~lhs_of_application
          ~function_decls ~closure_id_being_applied ~function_decl
          ~args ~args_approxs
          ~invariant_params:invariant_params
          ~specialised_args:value_set_of_closures.specialised_args
          ~free_vars:value_set_of_closures.free_vars
          ~direct_call_surrogates:value_set_of_closures.direct_call_surrogates
          ~dbg ~simplify ~inline_requested
      in
      match copied_function_declaration with
      | Some (expr, r_inlined) ->
        let wsb =
          W.create ~original expr
            ~toplevel:false
            ~branch_depth:(E.branch_depth env)
            ~lifting:false
            ~round:(E.round env)
            ~benefit:(R.benefit r_inlined)
        in
        let env =
          (* CR-someday lwhite: could avoid calculating this if stats is turned
             off *)
          let closure_ids =
            Closure_id.Set.of_list (
              List.map Closure_id.wrap
                (Variable.Set.elements (Variable.Map.keys function_decls.funs)))
          in
          E.note_entering_specialised env ~closure_ids
        in
        if always_specialise || W.evaluate wsb then begin
          let r_inlined =
            if always_specialise then
              R.map_benefit r_inlined
                (Inlining_cost.Benefit.max ~round:(E.round env)
                   Inlining_cost.Benefit.(requested_inline ~size_of:expr zero))
            else r_inlined
          in
          let r =
            R.map_benefit r_inlined (Inlining_cost.Benefit.(+) (R.benefit r))
          in
          let closure_env =
            let env =
              if E.inlining_level env = 0
               (* If the function was considered for specialising without
                  considering its sub-functions, and it is not below another
                  inlining choice, then we are certain that this code will
                  be kept. *)
              then env
              else E.inlining_level_up env
            in
              E.set_never_inline_outside_closures env
          in
          let application_env = E.set_never_inline_inside_closures env in
          let expr, r = simplify closure_env r expr in
          let res = simplify application_env r expr in
          let decision =
            if always_specialise then S.Specialised.Annotation
            else S.Specialised.Without_subfunctions wsb
          in
          Changed (res, decision)
        end else begin
          let closure_env =
            let env = E.inlining_level_up env in
            E.set_never_inline_outside_closures env
          in
          let expr, r_inlined = simplify closure_env r_inlined expr in
          let wsb_with_subfunctions =
            W.create ~original expr
              ~toplevel:false
              ~branch_depth:(E.branch_depth env)
              ~lifting:false
              ~round:(E.round env)
              ~benefit:(R.benefit r_inlined)
          in
          if W.evaluate wsb_with_subfunctions then begin
             let r =
               R.map_benefit r_inlined
                        (Inlining_cost.Benefit.(+) (R.benefit r))
             in
             let application_env = E.set_never_inline_inside_closures env in
             let res = simplify application_env r expr in
             let decision =
               S.Specialised.With_subfunctions (wsb, wsb_with_subfunctions)
             in
             Changed (res, decision)
          end else begin
            let decision =
              S.Not_specialised.Not_beneficial (wsb, wsb_with_subfunctions)
            in
            Original decision
          end
        end
      | None ->
        let decision = S.Not_specialised.No_useful_approximations in
        Original decision
    end

let for_call_site ~env ~r ~(function_decls : A.function_declarations)
      ~lhs_of_application ~closure_id_being_applied
      ~(function_decl : A.function_declaration)
      ~(value_set_of_closures : A.value_set_of_closures)
      ~args ~args_approxs ~dbg ~simplify ~inline_requested
      ~specialise_requested =
  if List.length args <> List.length args_approxs then begin
    Misc.fatal_error "Inlining_decision.for_call_site: inconsistent lengths \
        of [args] and [args_approxs]"
  end;
  (* Remove unroll attributes from functions we are already actively
     unrolling, otherwise they'll be unrolled again next round. *)
  let inline_requested : Lambda.inline_attribute =
    match (inline_requested : Lambda.inline_attribute) with
    | Unroll _ -> begin
        let unrolling =
          E.actively_unrolling env function_decls.set_of_closures_origin
        in
        match unrolling with
        | Some _ -> Default_inline
        | None -> inline_requested
      end
    | Always_inline | Hint_inline | Default_inline | Never_inline ->
        inline_requested
  in
  let original =
    Flambda.Apply {
      func = lhs_of_application;
      args;
      kind = Direct closure_id_being_applied;
      dbg;
      inline = inline_requested;
      specialise = specialise_requested;
    }
  in
  let original_r =
    R.set_approx (R.seen_direct_application r) (A.value_unknown Other)
  in
  match function_decl.function_body with
  | None -> original, original_r
  | Some { stub; _ } ->
    if stub then begin
      let fun_vars = Variable.Map.keys function_decls.funs in
      let function_body = get_function_body function_decl in
      let body, r =
        Inlining_transforms.inline_by_copying_function_body ~env
          ~r ~fun_vars ~lhs_of_application
          ~closure_id_being_applied ~specialise_requested ~inline_requested
          ~function_decl ~function_body ~args ~dbg ~simplify
      in
      simplify env r body
    end else if E.never_inline env then
      (* This case only occurs when examining the body of a stub function
         but not in the context of inlining said function.  As such, there
         is nothing to do here (and no decision to report). *)
      original, original_r
    else if function_decls.is_classic_mode then begin
      let env =
        E.note_entering_call env
          ~closure_id:closure_id_being_applied ~dbg:dbg
      in
      let simpl =
        match function_decl.function_body with
        | None -> Original S.Not_inlined.Classic_mode
        | Some function_body ->
          let self_call =
            E.inside_set_of_closures_declaration
              function_decls.set_of_closures_origin env
          in
          let try_inlining =
            if self_call then
              Don't_try_it S.Not_inlined.Self_call
            else
              if not (E.inlining_allowed env function_decl.closure_origin) then
                Don't_try_it S.Not_inlined.Unrolling_depth_exceeded
              else
                Try_it
          in
          match try_inlining with
          | Don't_try_it decision -> Original decision
          | Try_it ->
            let fun_vars = Variable.Map.keys function_decls.funs in
            let body, r =
              Inlining_transforms.inline_by_copying_function_body ~env
                ~r ~function_body ~lhs_of_application
                ~closure_id_being_applied ~specialise_requested
                ~inline_requested ~function_decl ~fun_vars ~args ~dbg ~simplify
            in
            let env = E.note_entering_inlined env in
            let env =
              (* We decrement the unrolling count even if the function is not
                 recursive to avoid having to check whether or not it is
                 recursive *)
              E.inside_unrolled_function env
                                         function_decls.set_of_closures_origin
            in
            let env =
              E.inside_inlined_function env function_decl.closure_origin
            in
            Changed ((simplify env r body), S.Inlined.Classic_mode)
      in
      let res, decision =
        match simpl with
        | Original decision ->
          let decision =
            S.Decision.Unchanged (S.Not_specialised.Classic_mode, decision)
          in
          (original, original_r), decision
        | Changed ((expr, r), decision) ->
          let max_inlining_threshold =
            if E.at_toplevel env then
              Inline_and_simplify_aux.initial_inlining_toplevel_threshold
                ~round:(E.round env)
            else
              Inline_and_simplify_aux.initial_inlining_threshold
                ~round:(E.round env)
          in
          let raw_inlining_threshold = R.inlining_threshold r in
          let unthrottled_inlining_threshold =
            match raw_inlining_threshold with
            | None -> max_inlining_threshold
            | Some inlining_threshold -> inlining_threshold
          in
          let inlining_threshold =
            T.min unthrottled_inlining_threshold max_inlining_threshold
          in
          let inlining_threshold_diff =
            T.sub unthrottled_inlining_threshold inlining_threshold
          in
          let res =
            if E.inlining_level env = 0
            then expr, R.set_inlining_threshold r raw_inlining_threshold
            else expr, R.add_inlining_threshold r inlining_threshold_diff
          in
          res, S.Decision.Inlined (S.Not_specialised.Classic_mode, decision)
      in
      E.record_decision env decision;
      res
    end else begin
      let function_body = get_function_body function_decl in
      let env = E.unset_never_inline_inside_closures env in
      let env =
        E.note_entering_call env
          ~closure_id:closure_id_being_applied ~dbg:dbg
      in
      let max_level =
        Clflags.Int_arg_helper.get ~key:(E.round env) !Clflags.inline_max_depth
      in
      let raw_inlining_threshold = R.inlining_threshold r in
      let max_inlining_threshold =
        if E.at_toplevel env then
          Inline_and_simplify_aux.initial_inlining_toplevel_threshold
            ~round:(E.round env)
        else
          Inline_and_simplify_aux.initial_inlining_threshold
            ~round:(E.round env)
      in
      let unthrottled_inlining_threshold =
        match raw_inlining_threshold with
        | None -> max_inlining_threshold
        | Some inlining_threshold -> inlining_threshold
      in
      let inlining_threshold =
        T.min unthrottled_inlining_threshold max_inlining_threshold
      in
      let inlining_threshold_diff =
        T.sub unthrottled_inlining_threshold inlining_threshold
      in
      let inlining_prevented =
        match inlining_threshold with
        | Never_inline -> true
        | Can_inline_if_no_larger_than _ -> false
      in
      let simpl =
        if inlining_prevented then
          Original (D.Prevented Function_prevented_from_inlining)
        else if E.inlining_level env >= max_level then
          Original (D.Prevented Level_exceeded)
        else begin
          let self_call =
            E.inside_set_of_closures_declaration
              function_decls.set_of_closures_origin env
          in
          let fun_cost =
            lazy
              (Inlining_cost.can_try_inlining function_body.body
                 inlining_threshold
                 ~number_of_arguments:(List.length function_decl.params)
                 (* CR-someday mshinwell: for the moment, this is None, since
                    the Inlining_cost code isn't checking sizes up to the max
                    inlining threshold---this seems to take too long. *)
                 ~size_from_approximation:None)
          in
          let recursive =
            lazy
              (let fun_var = Closure_id.unwrap closure_id_being_applied in
               Variable.Set.mem fun_var
                 (Lazy.force value_set_of_closures.recursive))
          in
          let specialise_result =
            specialise env r
              ~function_decls ~function_decl
              ~lhs_of_application ~recursive ~closure_id_being_applied
              ~value_set_of_closures ~args ~args_approxs ~dbg ~simplify
              ~original ~inline_requested ~specialise_requested ~fun_cost
              ~self_call ~inlining_threshold
          in
          match specialise_result with
          | Changed (res, spec_reason) ->
            Changed (res, D.Specialised spec_reason)
          | Original spec_reason ->
            let only_use_of_function = false in
            (* If we didn't specialise then try inlining *)
            let size_from_approximation =
              let fun_var = Closure_id.unwrap closure_id_being_applied in
              match
                Variable.Map.find fun_var
                                  (Lazy.force value_set_of_closures.size)
              with
              | size -> size
              | exception Not_found ->
                Misc.fatal_errorf "Approximation does not give a size for the \
                                   function having fun_var %a.  \
                                   value_set_of_closures: %a"
                  Variable.print fun_var
                  A.print_value_set_of_closures value_set_of_closures
            in
            let fun_vars = Variable.Map.keys function_decls.funs in
            let set_of_closures_origin =
              function_decls.set_of_closures_origin
            in
            let inline_result =
              inline env r ~lhs_of_application
                ~closure_id_being_applied ~function_decl ~value_set_of_closures
                ~only_use_of_function ~original ~recursive
                ~inline_requested ~specialise_requested
                ~fun_vars ~set_of_closures_origin ~args
                ~size_from_approximation ~dbg ~simplify ~fun_cost ~self_call
                ~inlining_threshold ~function_body
            in
            match inline_result with
            | Changed (res, inl_reason) ->
              Changed (res, D.Inlined (spec_reason, inl_reason))
            | Original inl_reason ->
              Original (D.Unchanged (spec_reason, inl_reason))
        end
      in
      let res, decision =
        match simpl with
        | Original decision -> (original, original_r), decision
        | Changed ((expr, r), decision) ->
          let res =
            if E.inlining_level env = 0
            then expr, R.set_inlining_threshold r raw_inlining_threshold
            else expr, R.add_inlining_threshold r inlining_threshold_diff
          in
          res, decision
      in
      E.record_decision env decision;
      res
    end

(* We do not inline inside stubs, which are always inlined at their call site.
   Inlining inside the declaration of a stub could result in more code than
   expected being inlined (e.g. the body of a function that was transformed
   by adding the stub). *)
let should_inline_inside_declaration (decl : Flambda.function_declaration) =
  not decl.stub
