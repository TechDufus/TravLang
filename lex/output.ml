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

(* Output the DFA tables and its entry points *)

open Printf
open Lexgen
open Compact
open Common

exception Table_overflow

let check_overflow ~min ~max v =
  Array.iter (fun n -> if n < min || n > max then raise Table_overflow) v

(* To output an array of short ints, encoded as a string *)

let output_byte oc b =
  output_char oc '\\';
  output_char oc (Char.chr(48 + b / 100));
  output_char oc (Char.chr(48 + (b / 10) mod 10));
  output_char oc (Char.chr(48 + b mod 10))

let output_array oc v =
  output_string oc "   \"";
  for i = 0 to Array.length v - 1 do
    output_byte oc (v.(i) land 0xFF);
    output_byte oc ((v.(i) asr 8) land 0xFF);
    if i land 7 = 7 then output_string oc "\\\n    "
  done;
  output_string oc "\""

let output_array_u oc v =
  check_overflow ~min:0 ~max: 0xFFFF v;
  output_array oc v

let output_array_s oc v =
  check_overflow ~min:(-0x8000) ~max: 0x7FFF v;
  output_array oc v

let output_byte_array oc v =
  check_overflow ~min:0 ~max:0xFF v;
  output_string oc "   \"";
  for i = 0 to Array.length v - 1 do
    output_byte oc (v.(i) land 0xFF);
    if i land 15 = 15 then output_string oc "\\\n    "
  done;
  output_string oc "\""

(* Output the tables *)

let output_tables oc tbl =
  output_string oc "let __travlang_lex_tables = {\n";

  fprintf oc "  Lexing.lex_base =\n%a;\n" output_array_s tbl.tbl_base;
  fprintf oc "  Lexing.lex_backtrk =\n%a;\n" output_array_s tbl.tbl_backtrk;
  fprintf oc "  Lexing.lex_default =\n%a;\n" output_array_s tbl.tbl_default;
  fprintf oc "  Lexing.lex_trans =\n%a;\n" output_array_s tbl.tbl_trans;
  fprintf oc "  Lexing.lex_check =\n%a;\n" output_array_s tbl.tbl_check;
  fprintf oc "  Lexing.lex_base_code =\n%a;\n" output_array_u tbl.tbl_base_code;

  fprintf oc "  Lexing.lex_backtrk_code =\n%a;\n"
    output_array_u tbl.tbl_backtrk_code;
  fprintf oc "  Lexing.lex_default_code =\n%a;\n"
    output_array_u tbl.tbl_default_code;
  fprintf oc "  Lexing.lex_trans_code =\n%a;\n"
    output_array_u tbl.tbl_trans_code;
  fprintf oc "  Lexing.lex_check_code =\n%a;\n"
    output_array_s tbl.tbl_check_code;
  fprintf oc "  Lexing.lex_code =\n%a;\n" output_byte_array tbl.tbl_code;

  output_string oc "}\n\n"


(* Output the entries *)

let output_entry some_mem_code ic oc has_refill oci e =
  let init_num, init_moves = e.auto_initial_state in
  (* Will use "memory" instructions when (1) some memory instructions are
     here and (2) this entry point needs memory. *)
  let some_mem_code = some_mem_code &&  e.auto_mem_size > 0 in
  fprintf oc
    "%s %alexbuf =\
   \n  %a%a __travlang_lex_%s_rec %alexbuf %d\n"
    e.auto_name
    output_args e.auto_args
    (fun oc x ->
      if some_mem_code then
        fprintf oc "lexbuf.Lexing.lex_mem <- Array.make %d (-1);" x)
    e.auto_mem_size
    (output_memory_actions "  ") init_moves
    e.auto_name
    output_args e.auto_args
    init_num;
  fprintf oc "and __travlang_lex_%s_rec %alexbuf __travlang_lex_state =\n"
    e.auto_name output_args e.auto_args;
  fprintf oc "  match Lexing.%sengine"
          (if some_mem_code then "new_" else "");
  fprintf oc " __travlang_lex_tables __travlang_lex_state lexbuf with\n    ";
  List.iter
    (fun (num, env, loc) ->
      fprintf oc "  | ";
      fprintf oc "%d ->\n" num;
      output_env ic oc oci env;
      copy_chunk ic oc oci loc true;
      fprintf oc "\n")
    e.auto_actions;
  if has_refill then
    fprintf oc
      "  | __travlang_lex_state -> __travlang_lex_refill\
     \n      (fun lexbuf -> lexbuf.Lexing.refill_buff lexbuf;\
     \n         __travlang_lex_%s_rec %alexbuf __travlang_lex_state) lexbuf\n\n"
      e.auto_name output_args e.auto_args
  else
    fprintf oc
      "  | __travlang_lex_state -> lexbuf.Lexing.refill_buff lexbuf;\
     \n      __travlang_lex_%s_rec %alexbuf __travlang_lex_state\n\n"
      e.auto_name output_args e.auto_args

(* Main output function *)

let output_lexdef ic oc oci header rh tables entry_points trailer =
  if not !Common.quiet_mode then
    Printf.printf "%d states, %d transitions, table size %d bytes\n"
      (Array.length tables.tbl_base)
      (Array.length tables.tbl_trans)
      (2 * (Array.length tables.tbl_base + Array.length tables.tbl_backtrk +
            Array.length tables.tbl_default + Array.length tables.tbl_trans +
            Array.length tables.tbl_check));
  let size_groups =
    (2 * (Array.length tables.tbl_base_code +
          Array.length tables.tbl_backtrk_code +
          Array.length tables.tbl_default_code +
          Array.length tables.tbl_trans_code +
          Array.length tables.tbl_check_code) +
    Array.length tables.tbl_code) in
  if size_groups > 0 && not !Common.quiet_mode then
    Printf.printf "%d additional bytes used for bindings\n" size_groups;
  flush stdout;
  if Array.length tables.tbl_trans > 0x8000 then raise Table_overflow;
  copy_chunk ic oc oci header false;
  let has_refill = output_refill_handler ic oc oci rh in
  output_tables oc tables;
  let some_mem_code = Array.length tables.tbl_code > 0 in
  begin match entry_points with
    [] -> ()
  | entry1 :: entries ->
    output_string oc "let rec ";
    output_entry some_mem_code ic oc has_refill oci entry1;
      List.iter
        (fun e ->
           output_string oc "and ";
           output_entry some_mem_code ic oc has_refill oci e)
        entries;
      output_string oc ";;\n\n";
  end;
  copy_chunk ic oc oci trailer false
