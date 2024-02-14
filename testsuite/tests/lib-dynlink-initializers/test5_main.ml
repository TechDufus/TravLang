(* TEST
 include dynlink;
 readonly_files = "test5_plugin_a.ml test5_plugin_b.ml test5_second_plugin.ml";
 libraries = "";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     module = "test5_main.ml";
     travlangc.byte;
   }{
     module = "test5_plugin_a.ml";
     travlangc.byte;
   }{
     module = "test5_plugin_b.ml";
     travlangc.byte;
   }{
     module = "test5_second_plugin.ml";
     travlangc.byte;
   }{
     program = "test5_plugin.cma";
     flags = "-a";
     all_modules = "test5_plugin_a.cmo test5_plugin_b.cmo";
     travlangc.byte;
   }{
     program = "${test_build_directory}/test5.byte";
     libraries = "dynlink";
     all_modules = "test5_main.cmo";
     travlangc.byte;
     run;
   }
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   {
     module = "test5_main.ml";
     travlangopt.byte;
   }{
     module = "test5_plugin_a.ml";
     travlangopt.byte;
   }{
     module = "test5_plugin_b.ml";
     travlangopt.byte;
   }{
     program = "test5_plugin.cmxs";
     flags = "-shared";
     all_modules = "test5_plugin_a.cmx test5_plugin_b.cmx";
     travlangopt.byte;
   }{
     program = "test5_second_plugin.cmxs";
     flags = "-shared";
     all_modules = "test5_second_plugin.ml";
     travlangopt.byte;
   }{
     program = "${test_build_directory}/test5.exe";
     libraries = "dynlink";
     all_modules = "test5_main.cmx";
     travlangopt.byte;
     run;
   }
 }
*)

(* Check that when one shared library loads another shared library then
   modules of the second shared library can refer to modules of the
   first shared library, as long as they have already been loaded. *)

let () =
  if Dynlink.is_native then
    Dynlink.loadfile "test5_plugin.cmxs"
  else
    Dynlink.loadfile "test5_plugin.cma"
