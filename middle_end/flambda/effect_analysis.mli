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

(** Simple side effect analysis. *)

(* CR-someday pchambart: Replace by call to [Purity] module.
   mshinwell: Where is the [Purity] module? *)
(** Conservative approximation as to whether a given Flambda expression may
    have any side effects. *)
val no_effects : Flambda.t -> bool

val no_effects_named : Flambda.named -> bool
