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

[@@@travlang.warning "+a-4-9-30-40-41-42"]

module type S = sig
  type t

  val simplify_unop
     : Clambda_primitives.primitive
    -> t Simple_value_approx.boxed_int
    -> Flambda.named
    -> t
    -> Flambda.named * Simple_value_approx.t * Inlining_cost.Benefit.t

  val simplify_binop
     : Clambda_primitives.primitive
    -> t Simple_value_approx.boxed_int
    -> Flambda.named
    -> t
    -> t
    -> Flambda.named * Simple_value_approx.t * Inlining_cost.Benefit.t

  val simplify_binop_int
     : Clambda_primitives.primitive
    -> t Simple_value_approx.boxed_int
    -> Flambda.named
    -> t
    -> int
    -> size_int:int
    -> Flambda.named * Simple_value_approx.t * Inlining_cost.Benefit.t
end
