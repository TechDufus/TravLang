(* TEST
 {
   setup-travlangc.byte-build-env;
   module = "empty.ml";
   travlangc.byte;
   module = "";
   flags = "-a";
   all_modules = "";
   program = "empty.cma";
   travlangc.byte;
   flags = "";
   program = "${test_build_directory}/empty.byte";
   all_modules = "empty.cma empty.cmo";
   travlangc.byte;
   check-travlangc.byte-output;
 }{
   setup-travlangopt.byte-build-env;
   module = "empty.ml";
   travlangopt.byte;
   module = "";
   flags = "-a";
   all_modules = "";
   program = "empty.cmxa";
   travlangopt.byte;
   flags = "";
   program = "${test_build_directory}/empty.native";
   all_modules = "empty.cmxa empty.cmx";
   travlangopt.byte;
   check-travlangopt.byte-output;
 }
*)
