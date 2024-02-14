(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*             Sebastien Hinderer, projet Gallium, INRIA Paris            *)
(*                                                                        *)
(*   Copyright 2018 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Locations of files in the travlang source tree *)

type runtime_variant =
  | Normal
  | Debug
  | Instrumented

val runtime_variant : unit -> runtime_variant

val travlangrun : string

val travlangc : string

val travlang : string

val travlangc_dot_opt : string

val travlangopt : string

val travlangopt_dot_opt : string

val travlangnat : string

val cmpbyt : string

val expect : string

val travlanglex : string

val travlangyacc : string

val travlangdoc : string
val travlangdebug : string
val travlangobjinfo : string
val travlangmklib : string
val codegen : string

val asmgen_archmod : string
