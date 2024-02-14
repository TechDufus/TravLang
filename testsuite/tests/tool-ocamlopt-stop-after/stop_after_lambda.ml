(* TEST
 no-flambda;
 setup-travlangopt.byte-build-env;
 flags = "-dlambda -stop-after lambda -nopervasives ";
 travlangopt_byte_exit_status = "0";
 travlangopt.byte;
 check-travlangopt.byte-output;
*)

(* no-flambda: the -lambda output differs with flambda, and
   maintaining two outputs is inconvenient for a test that is not
   really related to code generation. *)

external p : int -> unit = ""
let () = p 1
