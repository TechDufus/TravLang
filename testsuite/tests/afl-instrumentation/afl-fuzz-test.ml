(* TEST
 native-compiler;
 script = "sh ${test_source_directory}/has-afl-fuzz.sh";
 readonly_files = "readline.ml";
 script;
 setup-travlangopt.byte-build-env;
 program = "${test_build_directory}/readline";
 flags = "-afl-instrument";
 all_modules = "readline.ml";
 travlangopt.byte;
 run;
*)

(* No code here, this file is a pure test script. *)
