(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

(* Bad (t = t -> int) *)
module rec A : sig type t = B.t -> int end = struct type t = B.t -> int end
       and B : sig type t = A.t end = struct type t = A.t end;;

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
