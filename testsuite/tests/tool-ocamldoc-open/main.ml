(* TEST
 modules = "inner.ml alias.ml";
 travlangdoc_backend = "latex";
 travlangdoc_flags = " -open Alias.Container -open Aliased_inner ";
 travlangdoc;
*)

(** Documentation test *)

type t = a
(** Alias to type Inner.a *)
