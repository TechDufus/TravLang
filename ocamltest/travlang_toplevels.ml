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

(* Description of the travlang toplevels *)

open travlangtest_stdlib

class toplevel
  ~(name : string)
  ~(flags : string)
  ~(directory : string)
  ~(exit_status_variable : Variables.t)
  ~(reference_variable : Variables.t)
  ~(output_variable : Variables.t)
  ~(backend : travlang_backends.t)
  ~(compiler : travlang_compilers.compiler)
= object (self) inherit travlang_tools.tool
  ~name:name
  ~family:"toplevel"
  ~flags:flags
  ~directory:directory
  ~exit_status_variable:exit_status_variable
  ~reference_variable:reference_variable
  ~output_variable:output_variable
  as tool
  method backend = backend
  method compiler = compiler
  method ! reference_file env prefix =
    let default = tool#reference_file env prefix in
    if Sys.file_exists default then default else
    let suffix = self#reference_filename_suffix env in
    let mk s = (Filename.make_filename prefix s) ^ suffix in
    let filename = mk
      (travlang_backends.string_of_backend self#backend) in
    if Sys.file_exists filename then filename else
    mk "compilers"

end

let travlang = new toplevel
  ~name: travlang_commands.travlangrun_travlang
  ~flags: ""
  ~directory: "travlang"
  ~exit_status_variable: travlang_variables.travlang_exit_status
  ~reference_variable: travlang_variables.compiler_reference
  ~output_variable: travlang_variables.compiler_output
  ~backend: travlang_backends.Bytecode
  ~compiler: travlang_compilers.travlangc_byte

let travlangnat = new toplevel
  ~name: travlang_files.travlangnat
  ~flags: "-S" (* Keep intermediate assembly files *)
  ~directory: "travlangnat"
  ~exit_status_variable: travlang_variables.travlangnat_exit_status
  ~reference_variable: travlang_variables.compiler_reference2
  ~output_variable: travlang_variables.compiler_output2
  ~backend: travlang_backends.Native
  ~compiler: travlang_compilers.travlangc_opt
