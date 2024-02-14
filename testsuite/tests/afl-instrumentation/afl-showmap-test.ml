(* TEST
 native-compiler;
 script = "sh ${test_source_directory}/has-afl-showmap.sh";
 readonly_files = "harness.ml test.ml";
 script;
 setup-travlangopt.byte-build-env;
 module = "test.ml";
 flags = "-afl-instrument";
 travlangopt.byte;
 module = "";
 program = "${test_build_directory}/test";
 flags = "-afl-inst-ratio 0";
 all_modules = "test.cmx harness.ml";
 travlangopt.byte;
 run;
*)

(* No code here, this file is a pure test script. *)
