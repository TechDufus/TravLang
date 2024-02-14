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

(* Helper functions to build travlang-related commands *)

let travlangrun program =
  travlang_files.travlangrun ^ " " ^ program

let travlangrun_travlangc = travlangrun travlang_files.travlangc

let travlangrun_travlangopt = travlangrun travlang_files.travlangopt

let travlangrun_travlang = travlangrun travlang_files.travlang

let travlangrun_expect =
  travlangrun travlang_files.expect

let travlangrun_travlanglex = travlangrun travlang_files.travlanglex

let travlangrun_travlangdoc =
  travlangrun travlang_files.travlangdoc

let travlangrun_travlangdebug =
  travlangrun travlang_files.travlangdebug

let travlangrun_travlangobjinfo =
  travlangrun travlang_files.travlangobjinfo

let travlangrun_travlangmklib =
  travlangrun travlang_files.travlangmklib

let travlangrun_codegen =
  travlangrun travlang_files.codegen
