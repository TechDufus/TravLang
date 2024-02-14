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

(* Description of the travlang compilers *)

open travlangtest_stdlib

class compiler
  ~(name : string)
  ~(flags : string)
  ~(directory : string)
  ~(exit_status_variable : Variables.t)
  ~(reference_variable : Variables.t)
  ~(output_variable : Variables.t)
  ~(host : travlang_backends.t)
  ~(target : travlang_backends.t)
= object (self) inherit travlang_tools.tool
  ~name:name
  ~family:"compiler"
  ~flags:flags
  ~directory:directory
  ~exit_status_variable:exit_status_variable
  ~reference_variable:reference_variable
  ~output_variable:output_variable
  as tool

  method host = host
  method target = target

  method program_variable =
    if travlang_backends.is_native host && not Sys.win32
    then Builtin_variables.program2
    else Builtin_variables.program

  method program_output_variable =
    if travlang_backends.is_native host && not Sys.win32
    then None
    else Some Builtin_variables.output

  method ! reference_file env prefix =
    let default = tool#reference_file env prefix in
    if Sys.file_exists default then default else
    let suffix = self#reference_filename_suffix env in
    let mk s = (Filename.make_filename prefix s) ^ suffix in
    let filename = mk
      (travlang_backends.string_of_backend target) in
    if Sys.file_exists filename then filename else
    mk "compilers"
end

let travlangc_byte = new compiler
  ~name: travlang_commands.travlangrun_travlangc
  ~flags: ""
  ~directory: "travlangc.byte"
  ~exit_status_variable: travlang_variables.travlangc_byte_exit_status
  ~reference_variable: travlang_variables.compiler_reference
  ~output_variable: travlang_variables.compiler_output
  ~host: travlang_backends.Bytecode
  ~target: travlang_backends.Bytecode

let travlangc_opt = new compiler
  ~name: travlang_files.travlangc_dot_opt
  ~flags: ""
  ~directory: "travlangc.opt"
  ~exit_status_variable: travlang_variables.travlangc_opt_exit_status
  ~reference_variable: travlang_variables.compiler_reference2
  ~output_variable: travlang_variables.compiler_output2
  ~host: travlang_backends.Native
  ~target: travlang_backends.Bytecode

let travlangopt_byte = new compiler
  ~name: travlang_commands.travlangrun_travlangopt
  ~flags: ""
  ~directory: "travlangopt.byte"
  ~exit_status_variable: travlang_variables.travlangopt_byte_exit_status
  ~reference_variable: travlang_variables.compiler_reference
  ~output_variable: travlang_variables.compiler_output
  ~host: travlang_backends.Bytecode
  ~target: travlang_backends.Native

let travlangopt_opt = new compiler
  ~name: travlang_files.travlangopt_dot_opt
  ~flags: ""
  ~directory: "travlangopt.opt"
  ~exit_status_variable: travlang_variables.travlangopt_opt_exit_status
  ~reference_variable: travlang_variables.compiler_reference2
  ~output_variable: travlang_variables.compiler_output2
  ~host: travlang_backends.Native
  ~target: travlang_backends.Native
