(* TEST
 travlangdebug_script = "${test_source_directory}/input_script";
 debugger;
 shared-libraries;
 setup-travlangc.byte-build-env;
 script = "mkdir out";
 script;
 flags = "-g -c";
 all_modules = "${test_source_directory}/in/blah.ml";
 program = "out/blah.cmo";
 travlangc.byte;
 program = "out/foo.cmo";
 flags = "-I out -g -c";
 all_modules = "${test_source_directory}/in/foo.ml";
 travlangc.byte;
 all_modules = "out/blah.cmo out/foo.cmo";
 flags = " -g ";
 program = "debuggee.exe";
 travlangc.byte;
 check-travlangc.byte-output;
 travlangdebug;
 check-program-output;
*)

(* This file only contains the specification of how to run the test *)
