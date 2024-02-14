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

open travlangtest_stdlib

type runtime_variant =
  | Normal
  | Debug
  | Instrumented

let runtime_variant() =
  let use_runtime = Sys.safe_getenv "USE_RUNTIME" in
  if use_runtime="d" then Debug
  else if use_runtime="i" then Instrumented
  else Normal

let travlangrun =
  let runtime = match runtime_variant () with
    | Normal -> "travlangrun"
    | Debug -> "travlangrund"
    | Instrumented -> "travlangruni" in
  let travlangrunfile = Filename.mkexe runtime in
  Filename.make_path [travlang_directories.srcdir; "runtime"; travlangrunfile]

let travlangc =
  Filename.make_path [travlang_directories.srcdir; Filename.mkexe "travlangc"]

let travlang =
  Filename.make_path [travlang_directories.srcdir; Filename.mkexe "travlang"]

let travlangc_dot_opt =
  Filename.make_path [travlang_directories.srcdir; Filename.mkexe "travlangc.opt"]

let travlangopt =
  Filename.make_path [travlang_directories.srcdir; Filename.mkexe "travlangopt"]

let travlangopt_dot_opt =
  Filename.make_path [travlang_directories.srcdir; Filename.mkexe "travlangopt.opt"]

let travlangnat =
  Filename.make_path [travlang_directories.srcdir; Filename.mkexe "travlangnat"]

let cmpbyt =
  Filename.make_path
    [travlang_directories.srcdir; "tools"; Filename.mkexe "cmpbyt"]

let expect =
  Filename.make_path
    [travlang_directories.srcdir; "testsuite"; "tools";
     Filename.mkexe "expect"]

let travlanglex =
  Filename.make_path
    [travlang_directories.srcdir; "lex"; Filename.mkexe "travlanglex"]

let travlangyacc =
  Filename.make_path
    [travlang_directories.srcdir; "yacc"; Filename.mkexe "travlangyacc"]

let travlangdoc =
  Filename.make_path
    [travlang_directories.srcdir; "travlangdoc"; Filename.mkexe "travlangdoc"]

let travlangdebug =
  Filename.make_path
    [travlang_directories.srcdir; "debugger"; Filename.mkexe "travlangdebug"]

let travlangobjinfo =
  Filename.make_path
    [travlang_directories.srcdir; "tools"; Filename.mkexe "travlangobjinfo"]

let travlangmklib =
  Filename.make_path
    [travlang_directories.srcdir; "tools"; Filename.mkexe "travlangmklib"]

let codegen =
  Filename.make_path
    [travlang_directories.srcdir; "testsuite"; "tools"; Filename.mkexe "codegen"]

let asmgen_archmod =
  let objname =
    "asmgen_" ^ travlangtest_config.arch ^ "." ^ travlangtest_config.objext
  in
  Filename.make_path [travlang_directories.srcdir; "testsuite"; "tools"; objname]
