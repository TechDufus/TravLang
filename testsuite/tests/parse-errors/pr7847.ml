(* TEST_BELOW
(* Blank lines added here to preserve locations. *)



*)

(* https://caml.inria.fr/mantis/view.php?id=7847
   The backquote causes a syntax error; this file should be rejected. *)
external x : unit -> (int,int)`A.t = "x"

(* TEST
 setup-travlangc.byte-build-env;
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 check-travlangc.byte-output;
*)
