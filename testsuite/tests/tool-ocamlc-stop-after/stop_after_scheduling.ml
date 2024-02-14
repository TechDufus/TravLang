(* TEST
 compiler_output = "compiler-output.raw";
 setup-travlangc.byte-build-env;
 flags = "-stop-after scheduling";
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 script = "sh ${test_source_directory}/stop_after_scheduling.sh";
 output = "compiler-output";
 script;
 compiler_output = "compiler-output";
 check-travlangc.byte-output;
*)

(* this file is just a test driver, the test does not contain real travlang code *)
