(* TEST
 {
   setup-travlangopt.byte-build-env;
   travlangopt_byte_exit_status = "2";
   travlangopt.byte;
   check-travlangopt.byte-output;
 }{
   setup-travlangopt.opt-build-env;
   travlangopt_opt_exit_status = "2";
   travlangopt.opt;
   check-travlangopt.opt-output;
 }
*)

let[@poll error] c x =
  for c = 0 to 2 do
    ignore(Sys.opaque_identity(42))
  done
