(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*                       Pierre Chambart, travlangPro                        *)
(*           Mark Shinwell and Leo White, Jane Street Europe              *)
(*                                                                        *)
(*   Copyright 2013--2016 travlangPro SAS                                    *)
(*   Copyright 2014--2016 Jane Street Group LLC                           *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

val register : pass_name:string -> unit

val with_dump
   : ppf_dump:Format.formatter
  -> pass_name:string
  -> f:(unit -> 'b option)
  -> input:'a
  -> print_input:(Format.formatter -> 'a -> unit)
  -> print_output:(Format.formatter -> 'b -> unit)
  -> 'b option
