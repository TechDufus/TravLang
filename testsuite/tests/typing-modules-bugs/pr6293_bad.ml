(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

module type S = sig type t = { a : int; b : int; } end;;
let f (module M : S with type t = int) = { M.a = 0 };;

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
