(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

let main () =
  let args =
    Ccomp.quote_files ~response_files:true (List.tl (Array.to_list Sys.argv))
  in
  let travlangmktop = Sys.executable_name in
  (* On Windows Sys.command calls system() which in turn calls 'cmd.exe /c'.
     cmd.exe has special quoting rules (see 'cmd.exe /?' for details).
     Short version: if the string passed to cmd.exe starts with '"',
     the first and last '"' are removed *)
  let travlangc = "travlangc" ^ Config.ext_exe in
  let extra_quote = if Sys.win32 then "\"" else "" in
  let travlangc = Filename.(quote (concat (dirname travlangmktop) travlangc)) in
  let cmdline =
    extra_quote ^ travlangc ^
    " -I +compiler-libs " ^
    "-linkall travlangcommon.cma travlangbytecomp.cma travlangtoplevel.cma " ^
    args ^ " topstart.cmo" ^
    extra_quote
  in
  exit(Sys.command cmdline)

let _ = main ()
