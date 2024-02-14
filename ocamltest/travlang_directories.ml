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

(* Locations of directories in the travlang source tree *)

open travlangtest_stdlib

let srcdir =
  Sys.getenv_with_default_value "travlangSRCDIR" travlangtest_config.travlangsrcdir

let stdlib =
  Filename.make_path [srcdir; "stdlib"]

let libunix =
  Filename.make_path [srcdir; "otherlibs"; "unix"]

let toplevel =
  Filename.make_path [srcdir; "toplevel"]

let runtime =
  Filename.make_path [srcdir; "runtime"]

let tools =
  Filename.make_path [srcdir; "tools"]
