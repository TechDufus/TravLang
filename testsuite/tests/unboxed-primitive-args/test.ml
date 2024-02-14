(* TEST
 readonly_files = "common.mli common.ml test_common.c test_common.h";
 setup-travlangopt.byte-build-env;
 test_file = "${test_source_directory}/gen_test.ml";
 travlang_script_as_argument = "true";
 arguments = "c";
 compiler_output = "stubs.c";
 travlang;
 arguments = "ml";
 compiler_output = "main.ml";
 travlang;
 all_modules = "test_common.c stubs.c common.mli common.ml main.ml";
 travlangopt.byte;
 run;
 check-program-output;
*)
