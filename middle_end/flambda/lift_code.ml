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

type lifter = Flambda.program -> Flambda.program

type def =
  | Immutable of Variable.t * Flambda.named Flambda.With_free_variables.t
  | Mutable of Mutable_variable.t * Variable.t * Lambda.value_kind

let rebuild_let (defs : def list) (body : Flambda.t) =
  let module W = Flambda.With_free_variables in
  List.fold_left (fun body def ->
    match def with
    | Immutable(var, def) ->
        W.create_let_reusing_defining_expr var def body
    | Mutable(var, initial_value, contents_kind) ->
        Flambda.Let_mutable {var; initial_value; contents_kind; body})
    body defs

let rec extract_let_expr (acc:def list) (let_expr:Flambda.let_expr) :
  def list * Flambda.t Flambda.With_free_variables.t =
  let module W = Flambda.With_free_variables in
  let acc =
    match let_expr with
    | { var = v1; defining_expr = Expr (Let let2); _ } ->
        let acc, body2 = extract_let_expr acc let2 in
        Immutable(v1, W.expr body2) :: acc
    | { var = v1; defining_expr = Expr (Let_mutable let_mut); _ } ->
        let acc, body2 = extract_let_mutable acc let_mut in
        Immutable(v1, W.expr body2) :: acc
    | { var = v; _ } ->
        Immutable(v, W.of_defining_expr_of_let let_expr) :: acc
  in
  let body = W.of_body_of_let let_expr in
  extract acc body

and extract_let_mutable acc (let_mut : Flambda.let_mutable) =
  let module W = Flambda.With_free_variables in
  let { Flambda.var; initial_value; contents_kind; body } = let_mut in
  let acc = Mutable(var, initial_value, contents_kind) :: acc in
  extract acc (W.of_expr body)

and extract acc (expr : Flambda.t Flambda.With_free_variables.t) =
  let module W = Flambda.With_free_variables in
  match W.contents expr with
  | Let let_expr ->
    extract_let_expr acc let_expr
  | Let_mutable let_mutable ->
    extract_let_mutable acc let_mutable
  | _ ->
    acc, expr

let rec lift_lets_expr (expr:Flambda.t) ~toplevel : Flambda.t =
  let module W = Flambda.With_free_variables in
  match expr with
  | Let let_expr ->
    let defs, body = extract_let_expr [] let_expr in
    let rev_defs = List.rev_map (lift_lets_def ~toplevel) defs in
    let body = lift_lets_expr (W.contents body) ~toplevel in
    rebuild_let (List.rev rev_defs) body
  | Let_mutable let_mut ->
    let defs, body = extract_let_mutable [] let_mut in
    let rev_defs = List.rev_map (lift_lets_def ~toplevel) defs in
    let body = lift_lets_expr (W.contents body) ~toplevel in
    rebuild_let (List.rev rev_defs) body
  | e ->
    Flambda_iterators.map_subexpressions
      (lift_lets_expr ~toplevel)
      (lift_lets_named ~toplevel)
      e

and lift_lets_def def ~toplevel =
  let module W = Flambda.With_free_variables in
  match def with
  | Mutable _ -> def
  | Immutable(var, named) ->
    let named =
      match W.contents named with
      | Expr e -> W.expr (W.of_expr (lift_lets_expr e ~toplevel))
      | Set_of_closures set when not toplevel ->
        W.of_named
          (Set_of_closures
             (Flambda_iterators.map_function_bodies
                ~f:(lift_lets_expr ~toplevel) set))
      | Symbol _ | Const _ | Allocated_const _ | Read_mutable _
      | Read_symbol_field (_, _) | Project_closure _
      | Move_within_set_of_closures _ | Project_var _
      | Prim _ | Set_of_closures _ ->
        named
    in
    Immutable(var, named)

and lift_lets_named _var (named:Flambda.named) ~toplevel : Flambda.named =
  match named with
  | Expr e ->
    Expr (lift_lets_expr e ~toplevel)
  | Set_of_closures set when not toplevel ->
    Set_of_closures
      (Flambda_iterators.map_function_bodies ~f:(lift_lets_expr ~toplevel) set)
  | Symbol _ | Const _ | Allocated_const _ | Read_mutable _
  | Read_symbol_field (_, _) | Project_closure _ | Move_within_set_of_closures _
  | Project_var _ | Prim _ | Set_of_closures _ ->
    named

let lift_lets program =
  Flambda_iterators.map_exprs_at_toplevel_of_program program
    ~f:(lift_lets_expr ~toplevel:false)

let lifting_helper exprs ~evaluation_order ~create_body ~name =
  let vars, lets =
    (* [vars] corresponds elementwise to [exprs]; the order is unchanged. *)
    List.fold_right (fun (flam : Flambda.t) (vars, lets) ->
        match flam with
        | Var v ->
          (* Note that [v] is (statically) always an immutable variable. *)
          v::vars, lets
        | expr ->
          let v =
            Variable.create name ~current_compilation_unit:
                (Compilation_unit.get_current_exn ())
          in
          v::vars, (v, expr)::lets)
      exprs ([], [])
  in
  let lets =
    match evaluation_order with
    | `Right_to_left -> lets
    | `Left_to_right -> List.rev lets
  in
  List.fold_left (fun body (v, expr) ->
      Flambda.create_let v (Expr expr) body)
    (create_body vars) lets
