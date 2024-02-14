(* TEST
 include dynlink;
 readonly_files = "host.ml plugin.ml";
 libraries = "";
 flags += " -g ";
 travlangdebug_script = "${test_source_directory}/input_script";
 debugger;
 shared-libraries;
 setup-travlangc.byte-build-env;
 module = "host.ml";
 travlangc.byte;
 module = "plugin.ml";
 travlangc.byte;
 module = "";
 all_modules = "host.cmo";
 program = "${test_build_directory}/host.byte";
 libraries = "dynlink";
 travlangc.byte;
 output = "host.output";
 run;
 {
   reference = "${test_source_directory}/host.reference";
   check-program-output;
 }{
   output = "host.debug.output";
   travlangdebug;
   reference = "${test_source_directory}/host.debug.reference";
   check-program-output;
 }
*)

let () = print_endline "hello host"; Dynlink.loadfile "plugin.cmo"
