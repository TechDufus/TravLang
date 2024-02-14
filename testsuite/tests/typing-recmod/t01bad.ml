(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

(* Bad (t = t) *)
module rec A : sig type t = A.t end = struct type t = A.t end;;

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
