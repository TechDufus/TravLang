(* TEST
 setup-travlangc.byte-build-env;
 flags = "-dlambda -stop-after lambda -nopervasives ";
 travlangc_byte_exit_status = "0";
 travlangc.byte;
 check-travlangc.byte-output;
*)

external p : int -> unit = ""
let () = p 1
