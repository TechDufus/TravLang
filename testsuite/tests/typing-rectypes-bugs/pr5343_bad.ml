(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

module M : sig
  type 'a t
  type u = u t and v = v t
  val f : int -> u
  val g : v -> bool
end = struct
  type 'a t = 'a
  type u = int and v = bool
  let f x = x
  let g x = x
end;;

let h (x : int) : bool = M.g (M.f x);;

(* TEST
 flags = " -w -a -rectypes ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
