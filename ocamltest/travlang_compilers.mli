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

(* Descriptions of the travlang compilers *)

class compiler :
  name : string ->
  flags : string ->
  directory : string ->
  exit_status_variable : Variables.t ->
  reference_variable : Variables.t ->
  output_variable : Variables.t ->
  host : travlang_backends.t ->
  target : travlang_backends.t ->
object inherit travlang_tools.tool
  method host : travlang_backends.t
  method target : travlang_backends.t
  method program_variable : Variables.t
  method program_output_variable : Variables.t option
end

val travlangc_byte : compiler

val travlangc_opt : compiler

val travlangopt_byte : compiler

val travlangopt_opt : compiler
