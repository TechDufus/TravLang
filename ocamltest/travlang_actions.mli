(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*             Sebastien Hinderer, projet Gallium, INRIA Paris            *)
(*                                                                        *)
(*   Copyright 2017 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Actions specific to the travlang compilers *)

exception Cannot_compile_file_type of string

val setup_travlangc_byte_build_env : Actions.t
val travlangc_byte : Actions.t
val check_travlangc_byte_output : Actions.t
val setup_travlangc_opt_build_env : Actions.t
val travlangc_opt : Actions.t
val check_travlangc_opt_output : Actions.t
val setup_travlangopt_byte_build_env : Actions.t
val travlangopt_byte : Actions.t
val check_travlangopt_byte_output : Actions.t
val setup_travlangopt_opt_build_env : Actions.t
val travlangopt_opt : Actions.t
val check_travlangopt_opt_output : Actions.t
val run_expect : Actions.t
val compare_bytecode_programs : Actions.t
val compare_binary_files : Actions.t
val setup_travlang_build_env : Actions.t
val travlang : Actions.t
val check_travlang_output : Actions.t
val setup_travlangnat_build_env : Actions.t
val travlangnat : Actions.t
val check_travlangnat_output : Actions.t

val setup_travlangdoc_build_env : Actions.t
val run_travlangdoc: Actions.t
val check_travlangdoc_output: Actions.t

val flat_float_array : Actions.t
val no_flat_float_array : Actions.t

val shared_libraries : Actions.t
val no_shared_libraries : Actions.t

val native_compiler : Actions.t

val afl_instrument : Actions.t
val no_afl_instrument : Actions.t

val codegen : Actions.t

val cc : Actions.t
