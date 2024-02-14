(* TEST_BELOW
(* Blank lines added here to preserve locations. *)








*)

let[@poll error] rec c x l =
  match l with
  | [] -> 0
  | _ :: tl -> (c[@tailcall]) (x+1) tl

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
