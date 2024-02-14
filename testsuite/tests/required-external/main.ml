(* TEST
 modules = "file.ml";
 {
   program = "${test_build_directory}/main.exe";
   setup-travlangc.byte-build-env;
   module = "file.ml";
   travlangc.byte;
   module = "";
   program = "lib.cma";
   flags = "-a";
   all_modules = "file.cmo";
   travlangc.byte;
   program = "${test_build_directory}/main.exe";
   all_modules = "lib.cma main.ml";
   flags = "";
   travlangc.byte;
   check-travlangc.byte-output;
   run;
   check-program-output;
 }{
   program = "${test_build_directory}/main.exe";
   setup-travlangopt.byte-build-env;
   module = "file.ml";
   travlangopt.byte;
   module = "";
   program = "lib.cmxa";
   flags = "-a";
   all_modules = "file.cmx";
   travlangopt.byte;
   program = "${test_build_directory}/main.exe";
   all_modules = "lib.cmxa main.ml";
   flags = "";
   travlangopt.byte;
   check-travlangopt.byte-output;
   run;
   check-program-output;
 }
*)

let () =
  ignore (File.getcwd ())
