(* TEST
 setup-travlangc.byte-build-env;
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 check-travlangc.byte-output;
*)

class c = object
  method x = 1
