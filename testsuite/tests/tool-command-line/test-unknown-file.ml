(* TEST
 readonly_files = "unknown-file";
 {
   compiler_output = "compiler-output.raw";
   setup-travlangc.byte-build-env;
   all_modules = "";
   flags = "unknown-file";
   travlangc_byte_exit_status = "2";
   travlangc.byte;
   script = "grep 'know what to do with unknown-file' compiler-output.raw";
   output = "compiler-output";
   script;
   compiler_output = "compiler-output";
   check-travlangc.byte-output;
 }{
   compiler_output = "compiler-output.raw";
   setup-travlangopt.byte-build-env;
   all_modules = "";
   flags = "unknown-file";
   travlangopt_byte_exit_status = "2";
   travlangopt.byte;
   script = "grep 'know what to do with unknown-file' compiler-output.raw";
   output = "compiler-output";
   script;
   compiler_output = "compiler-output";
   check-travlangopt.byte-output;
 }
*)

(*
  This file is just a test driver, the test does not contain any
  real travlang code
*)
