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

type t = int

include Identifiable.Make (Numbers.Int)

let create_exn tag =
  if tag < 0 || tag > 255 then
    Misc.fatal_error (Printf.sprintf "Tag.create_exn %d" tag)
  else
    tag

let to_int t = t

let zero = 0
let object_tag = Obj.object_tag

let compare : t -> t -> int = Stdlib.compare
