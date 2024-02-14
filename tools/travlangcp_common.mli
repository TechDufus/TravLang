(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1998 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* This module shares the definitions common to both travlangcp and travlangoptp *)

(* Arguments recognized by travlangcp and travlangoptp *)
module type travlangcp_args =
  sig
    val _a : unit -> unit
    val _impl : string -> unit
    val _intf : string -> unit
    val _pp : string -> unit
    val _ppx : string -> unit
    val anonymous : string -> unit
  end

(* Description of one profiler *)
module type travlangCP =
  sig
    val bytecode : bool
    module Make_options : travlangcp_args -> Main_args.Arg_list
  end

(* Functor to build a profiler from its description *)
module Make : travlangCP ->
    sig
      val name : string
      val make_archive : bool ref
      val with_impl : bool ref
      val with_intf : bool ref
      val with_mli : bool ref
      val with_ml : bool ref
      val process_file : string -> unit
      val usage : string
      val incompatible : string -> 'a
      module Options : Main_args.Arg_list
      val rev_compargs : string list ref
      val rev_profargs : string list ref
      val add_profarg : string -> unit
      val anon : string -> unit
      val optlist : (string * Arg.spec * string) list
      val main : unit -> 'a
    end
