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

(* Flags used in travlang commands *)

let stdlib =
  let stdlib_path = travlang_directories.stdlib in
  "-nostdlib -I " ^ stdlib_path

let include_toplevel_directory =
  "-I " ^ travlang_directories.toplevel

let c_includes =
  let dir = travlang_directories.runtime in
  "-ccopt -I" ^ dir

let runtime_variant_flags () = match travlang_files.runtime_variant() with
  | travlang_files.Normal -> ""
  | travlang_files.Debug -> " -runtime-variant d"
  | travlang_files.Instrumented -> " -runtime-variant i"

let runtime_flags env backend c_files =
  let runtime_library_flags = "-I " ^
    travlang_directories.runtime in
  let rt_flags = match backend with
    | travlang_backends.Native -> runtime_variant_flags ()
    | travlang_backends.Bytecode ->
      begin
        if c_files then begin (* custom mode *)
          "-custom " ^ (runtime_variant_flags ())
        end else begin (* non-custom mode *)
          let use_runtime =
            Environments.lookup_as_bool travlang_variables.use_runtime env
          in
          if use_runtime = Some false
          then ""
          else "-use-runtime " ^ travlang_files.travlangrun
        end
      end in
  rt_flags ^ " " ^ runtime_library_flags

let toplevel_default_flags = "-noinit -no-version -noprompt"

let travlangdebug_default_flags =
  "-no-version -no-prompt -no-time -no-breakpoint-message " ^
  ("-I " ^ travlang_directories.stdlib ^ " ")

let travlangobjinfo_default_flags = "-null-crc"
