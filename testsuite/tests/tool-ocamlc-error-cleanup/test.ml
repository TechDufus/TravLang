(* TEST
 compiler_output = "compiler-output.raw";
 setup-travlangc.byte-build-env;
 all_modules = "test.ml";
 flags = "-warn-error +A";
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 script = "sh ${test_source_directory}/check-error-cleanup.sh";
 script;
*)

(* Regression test for MPR#7918 *)
let f () =
  (* -warn-error +A will error with unused x below *)
  let x = 12 in
  1
