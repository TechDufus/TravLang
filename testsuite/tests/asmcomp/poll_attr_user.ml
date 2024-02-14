(* TEST_BELOW
(* Blank lines added here to preserve locations. *)








*)

let[@inline never][@local never] v x = x + 1

let[@poll error] c x =
  let y = Sys.opaque_identity(ref 42) in
    let x2 = v x in
      for c = 0 to x2 do
        ignore(Sys.opaque_identity(ref 42))
      done;
      x2 + !y

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
