(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

(* Bad (t = int * t) *)
module rec A : sig type t = int * A.t end = struct type t = int * A.t end;;

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
