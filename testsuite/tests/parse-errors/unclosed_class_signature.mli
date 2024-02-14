(* TEST
 setup-travlangc.byte-build-env;
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 check-travlangc.byte-output;
*)

(* It is apparently impossible to get the "unclosed object" message. *)

class c : object
