(* TEST
 include dynlink;
 readonly_files = "lib.ml lib2.ml test.c";
 ld_library_path += "${test_build_directory}";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   compile_only = "true";
   all_modules = "lib.ml lib2.ml test.c dyn.ml";
   travlangc.byte;
   program = "lib";
   modules = "lib.cmo test.${objext}";
   compile_only = "false";
   travlangmklib;
   program = "lib2.cma";
   libraries = "";
   all_modules = "lib2.cmo";
   compile_only = "false";
   flags = "-a";
   travlangc.byte;
   libraries += "dynlink";
   program = "${test_build_directory}/main.exe";
   all_modules = "dyn.cmo";
   flags = "";
   travlangc.byte;
   output = "main.output";
   run;
   check-program-output;
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   compile_only = "true";
   all_modules = "lib.ml lib2.ml test.c dyn.ml";
   travlangopt.byte;
   program = "test";
   modules = "test.${objext}";
   compile_only = "false";
   travlangmklib;
   program = "lib.cmxs";
   libraries = "";
   flags = "-shared -cclib -L. -cclib -ltest";
   all_modules = "lib.cmx";
   compile_only = "false";
   travlangopt.byte;
   program = "lib2.cmxs";
   all_modules = "lib2.cmx";
   compile_only = "false";
   flags = "-shared";
   travlangopt.byte;
   libraries += "dynlink";
   program = "${test_build_directory}/main.exe";
   all_modules = "dyn.cmx";
   flags = "";
   travlangopt.byte;
   output = "main.output";
   run;
   check-program-output;
 }
*)
let () =
  Dynlink.allow_unsafe_modules true;
  Dynlink.adapt_filename "lib.cma" |> Dynlink.loadfile;
  Dynlink.adapt_filename "lib2.cma" |> Dynlink.loadfile
