(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*             Sebastien Hinderer, projet Gallium, INRIA Paris            *)
(*                                                                        *)
(*   Copyright 2016 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Definition of a few travlang-specific environment modifiers *)

open travlangtest_stdlib
open Environments

let wrap sl = " " ^ String.concat " " sl ^ " "
let append var sl = Append (var, wrap sl)
let add var s = Add (var, s)

let principal =
[
  append travlang_variables.flags ["-principal"];
  add travlang_variables.compiler_directory_suffix ".principal";
  add travlang_variables.compiler_reference_suffix ".principal";
]

let latex =
  [
    add travlang_variables.travlangdoc_backend "latex";
    append travlang_variables.travlangdoc_flags ["-latex-type-prefix=TYP"];
    append travlang_variables.travlangdoc_flags ["-latex-module-prefix="];
    append travlang_variables.travlangdoc_flags ["-latex-value-prefix="];
    append travlang_variables.travlangdoc_flags ["-latex-module-type-prefix="];
    append travlang_variables.travlangdoc_flags ["-latextitle=1,subsection*"];
    append travlang_variables.travlangdoc_flags ["-latextitle=2,subsubsection*"];
    append travlang_variables.travlangdoc_flags ["-latextitle=6,subsection*"];
    append travlang_variables.travlangdoc_flags ["-latextitle=7,subsubsection*"];
  ]


let html =
  [
    add travlang_variables.travlangdoc_backend "html";
    append travlang_variables.travlangdoc_flags ["-colorize-code"];
  ]

let man =
  [
    add travlang_variables.travlangdoc_backend "man";
  ]

let make_library_modifier library directories =
[
  append travlang_variables.directories directories;
  append travlang_variables.libraries [library];
  append travlang_variables.caml_ld_library_path directories;
]

let make_module_modifier unit_name directory =
[
  append travlang_variables.directories [directory];
  append travlang_variables.binary_modules [unit_name];
]

let compiler_subdir subdir =
  Filename.make_path (travlangtest_config.travlangsrcdir :: subdir)

let config =
[
  append travlang_variables.directories [compiler_subdir ["utils"]];
]

let testing = make_library_modifier
  "testing" [compiler_subdir ["testsuite"; "lib"]]

let tool_travlang_lib = make_module_modifier
  "lib" (compiler_subdir ["testsuite"; "lib"])

let unix = make_library_modifier
  "unix" [compiler_subdir ["otherlibs"; "unix"]]

let dynlink =
  make_library_modifier "dynlink"
    [compiler_subdir ["otherlibs"; "dynlink"];
     compiler_subdir ["otherlibs"; "dynlink"; "native"]]

let str = make_library_modifier
  "str" [compiler_subdir ["otherlibs"; "str"]]

let systhreads =
  unix @
  (make_library_modifier
    "threads" [compiler_subdir ["otherlibs"; "systhreads"]])

let runtime_events =
  make_library_modifier
    "runtime_events" [compiler_subdir ["otherlibs"; "runtime_events"]]

let compilerlibs_subdirs =
[
  "asmcomp";
  "bytecomp";
  "compilerlibs";
  "driver";
  "file_formats";
  "lambda";
  "middle_end";
  "parsing";
  "toplevel";
  "typing";
  "utils";
]

let add_compiler_subdir subdir =
  append travlang_variables.directories [compiler_subdir [subdir]]

let compilerlibs_archive archive =
  append travlang_variables.libraries [archive] ::
  List.map add_compiler_subdir compilerlibs_subdirs

let debugger = [add_compiler_subdir "debugger"]

let _ =
  register_modifiers "principal" principal;
  register_modifiers "config" config;
  register_modifiers "testing" testing;
  register_modifiers "unix" unix;
  register_modifiers "dynlink" dynlink;
  register_modifiers "str" str;
  List.iter
    (fun archive -> register_modifiers archive (compilerlibs_archive archive))
    [
      "travlangcommon";
      "travlangbytecomp";
      "travlangmiddleend";
      "travlangoptcomp";
      "travlangtoplevel";
    ];
  register_modifiers "runtime_events" runtime_events;
  register_modifiers "systhreads" systhreads;
  register_modifiers "latex" latex;
  register_modifiers "html" html;
  register_modifiers "man" man;
  register_modifiers "tool-travlang-lib" tool_travlang_lib;
  register_modifiers "debugger" debugger;
  ()
