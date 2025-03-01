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

external global_data : unit -> Obj.t array = "caml_get_global_data"
external realloc_global_data : int -> unit = "caml_realloc_global"
type closure = unit -> Obj.t
type bytecode
external reify_bytecode :
  (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t ->
  Instruct.debug_event list array -> string option ->
    bytecode * closure
                           = "caml_reify_bytecode"
external release_bytecode : bytecode -> unit
                                 = "caml_static_release_bytecode"
external invoke_traced_function : Obj.raw_data -> Obj.t -> Obj.t -> Obj.t
                                = "caml_invoke_traced_function"
