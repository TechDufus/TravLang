(* TEST
 readonly_files = "a.ml b.ml";
 travlangdebug_script = "${test_source_directory}/input_script";
 debugger;
 shared-libraries;
 setup-travlangc.byte-build-env;
 module = "a.ml";
 flags = "-g -for-pack foo";
 travlangc.byte;
 module = "";
 all_modules = "a.cmo";
 program = "foo.cmo";
 flags = "-g -pack";
 travlangc.byte;
 module = "b.ml";
 flags = " -g ";
 travlangc.byte;
 module = "";
 flags = " -g ";
 all_modules = "foo.cmo b.cmo";
 program = "${test_build_directory}/noev.exe";
 travlangc.byte;
 check-travlangc.byte-output;
 travlangdebug;
 check-program-output;
*)

(* This file only contains the specification of how to run the test *)
