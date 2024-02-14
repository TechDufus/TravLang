(* TEST
 setup-travlangopt.opt-build-env;
 all_modules = "";
 compile_only = "true";
 travlangopt_opt_exit_status = "2";
 flags = "";
 travlangopt.opt;
 flags = "-o test.exe";
 travlangopt.opt;
 check-travlangopt.opt-output;
*)

(*
  This file is just a test driver, the test does not contain any
  real travlang code
 *)
