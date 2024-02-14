(* TEST
 native-compiler;
 setup-travlangopt.byte-build-env;
 flags = "-stop-after scheduling -S";
 travlangopt_byte_exit_status = "0";
 travlangopt.byte;
 check-travlangopt.byte-output;
 script = "sh ${test_source_directory}/stop_after_scheduling.sh";
 script;
*)

(* this file is just a test driver, the test does not contain real travlang code *)
