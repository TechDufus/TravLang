(* TEST
 setup-travlangopt.opt-build-env;
 all_modules = "foo.c bar.c";
 compile_only = "true";
 flags = "-o outputdir/baz.${objext}";
 travlangopt_opt_exit_status = "2";
 travlangopt.opt;
 check-travlangopt.opt-output;
*)

(*
  This test makes sure that the -o option is rejected when trying to
  compile several C files during the same invocatin of the travlang compiler.
  The test does not need to contain any travlang code.
*)
