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

(* Types of files involved in an travlang project and related functions *)

type backend_specific = Object | Library | Program

type t =
  | Implementation
  | Interface
  | C
  | C_minus_minus
  | Lexer
  | Grammar
  | Binary_interface
  | Obj
  | Backend_specific of travlang_backends.t * backend_specific
  | Text (* used by travlangdoc for text only documentation *)
  | Other of string

let string_of_backend_specific = function
  | Object -> "object"
  | Library -> "library"
  | Program -> "program"

let string_of_filetype = function
  | Implementation -> "implementation"
  | Interface -> "interface"
  | C -> "C source file"
  | C_minus_minus -> "C minus minus source"
  | Lexer -> "lexer"
  | Grammar -> "grammar"
  | Binary_interface -> "binary interface"
  | Obj -> "object"
  | Backend_specific (backend, filetype) ->
    ((travlang_backends.string_of_backend backend) ^ " " ^
      (string_of_backend_specific filetype))
  | Text -> "text"
  | Other s -> Printf.sprintf "unknown (%s)" s

let extension_of_filetype = function
  | Implementation -> "ml"
  | Interface -> "mli"
  | C -> "c"
  | C_minus_minus -> "cmm"
  | Lexer -> "mll"
  | Grammar -> "mly"
  | Binary_interface -> "cmi"
  | Obj -> travlangtest_config.objext
  | Backend_specific (backend, filetype) ->
    begin match (backend, filetype) with
      | (travlang_backends.Native, Object) -> "cmx"
      | (travlang_backends.Native, Library) -> "cmxa"
      | (travlang_backends.Native, Program) -> "opt"
      | (travlang_backends.Bytecode, Object) -> "cmo"
      | (travlang_backends.Bytecode, Library) -> "cma"
      | (travlang_backends.Bytecode, Program) -> "byte"
    end
  | Text -> "txt"
  | Other s -> s

let filetype_of_extension = function
  | "ml" -> Implementation
  | "mli" -> Interface
  | "c" -> C
  | "cmm" -> C_minus_minus
  | "mll" -> Lexer
  | "mly" -> Grammar
  | "cmi" -> Binary_interface
  | "o" -> Obj
  | "obj" -> Obj
  | "cmx" -> Backend_specific (travlang_backends.Native, Object)
  | "cmxa" -> Backend_specific (travlang_backends.Native, Library)
  | "opt" -> Backend_specific (travlang_backends.Native, Program)
  | "cmo" -> Backend_specific (travlang_backends.Bytecode, Object)
  | "cma" -> Backend_specific (travlang_backends.Bytecode, Library)
  | "byte" -> Backend_specific (travlang_backends.Bytecode, Program)
  | "txt" -> Text
  | e -> Other e

let split_filename name =
  let l = String.length name in
  let is_dir_sep name i = name.[i] = Filename.dir_sep.[0] in
  let rec search_dot i =
    if i < 0 || is_dir_sep name i then (name, "")
    else if name.[i] = '.' then
      let basename = String.sub name 0 i in
      let extension = String.sub name (i+1) (l-i-1) in
      (basename, extension)
    else search_dot (i - 1) in
  search_dot (l - 1)

let filetype filename =
  let (basename, extension) = split_filename filename in
  (basename, filetype_of_extension extension)

let make_filename (basename, filetype) =
  let extension = extension_of_filetype filetype in
  basename ^ "." ^ extension

let action_of_filetype = function
  | Implementation -> "Compiling implementation"
  | Interface -> "Compiling interface"
  | C -> "Compiling C source file"
  | C_minus_minus -> "Processing C-- file"
  | Lexer -> "Generating lexer"
  | Grammar -> "Generating parser"
  | filetype -> ("nothing to do for " ^ (string_of_filetype filetype))
