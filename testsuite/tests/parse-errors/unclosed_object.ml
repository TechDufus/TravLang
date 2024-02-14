(* TEST
 setup-travlangc.byte-build-env;
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 check-travlangc.byte-output;
*)

(* Failed to get the unclosed object error message. *)

let o = object
