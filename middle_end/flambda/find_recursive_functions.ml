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

let in_function_declarations (function_decls : Flambda.function_declarations)
      ~backend =
  let module VCC = Strongly_connected_components.Make (Variable) in
  let directed_graph =
    let module B = (val backend : Backend_intf.S) in
    Flambda_utils.fun_vars_referenced_in_decls function_decls
      ~closure_symbol:B.closure_symbol
  in
  let connected_components =
    VCC.connected_components_sorted_from_roots_to_leaf directed_graph
  in
  Array.fold_left (fun rec_fun -> function
      | VCC.No_loop _ -> rec_fun
      | VCC.Has_loop elts -> List.fold_right Variable.Set.add elts rec_fun)
    Variable.Set.empty connected_components
