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

(* Descriptions of the travlang tools *)

open travlangtest_stdlib

class tool
  ~(name : string)
  ~(family : string)
  ~(flags : string)
  ~(directory : string)
  ~(exit_status_variable : Variables.t)
  ~(reference_variable : Variables.t)
  ~(output_variable : Variables.t)
= object (self)
  method name = name
  method family = family
  method flags = flags
  method directory = directory
  method exit_status_variable = exit_status_variable
  method reference_variable = reference_variable
  method output_variable = output_variable

  method reference_filename_suffix env =
    let tool_reference_suffix =
      Environments.safe_lookup travlang_variables.compiler_reference_suffix env
    in
    if tool_reference_suffix<>""
    then tool_reference_suffix ^ ".reference"
    else ".reference"

  method reference_file env prefix =
    let suffix = self#reference_filename_suffix env in
    (Filename.make_filename prefix directory) ^ suffix
end

let expected_exit_status env tool =
  Actions_helpers.exit_status_of_variable env tool#exit_status_variable


let travlangdoc =
  object inherit
  tool
    ~name:travlang_files.travlangdoc
    ~family:"doc"
    ~flags:""
    ~directory:"travlangdoc"
    ~exit_status_variable:travlang_variables.travlangdoc_exit_status
    ~reference_variable:travlang_variables.travlangdoc_reference
    ~output_variable:travlang_variables.travlangdoc_output

    method ! reference_filename_suffix env =
      let backend =
        Environments.safe_lookup travlang_variables.travlangdoc_backend env in
      if backend = "" then
        ".reference"
      else "." ^ backend ^ ".reference"
  end
