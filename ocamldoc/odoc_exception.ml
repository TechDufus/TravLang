(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*             Maxence Guesdon, projet Cristal, INRIA Rocquencourt        *)
(*                                                                        *)
(*   Copyright 2001 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(** Representation and manipulation of exceptions. *)

module Name = Odoc_name

type exception_alias = {
    ea_name : Name.t ;
    mutable ea_ex : t_exception option ;
  }

and t_exception = {
    ex_name : Name.t ;
    mutable ex_info : Odoc_types.info option ; (** optional user information *)
    ex_args : Odoc_type.constructor_args ; (** the types of the parameters *)
    ex_ret: Types.type_expr option ; (** the optional return type *)
    ex_alias : exception_alias option ;
    mutable ex_loc : Odoc_types.location ;
    mutable ex_code : string option ;
  }
