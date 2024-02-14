(* TEST
 readonly_files = "hello.c";
 setup-travlangopt.opt-build-env;
 script = "mkdir outputdir";
 script;
 all_modules = "hello.c";
 compile_only = "true";
 flags = "-o outputdir/hello.${objext}";
 travlangopt.opt;
 file = "outputdir/hello.${objext}";
 file-exists;
*)

(*
  This test makes sure it is possible to specify the name of the output
  object file when compiling a C file with the travlang compiler.
  The test does not need to contain any travlang code.
*)
