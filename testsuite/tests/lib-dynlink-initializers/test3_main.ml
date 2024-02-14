(* TEST
 include dynlink;
 readonly_files = "test3_plugin_a.ml test3_plugin_b.ml";
 libraries = "";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     module = "test3_main.ml";
     travlangc.byte;
   }{
     module = "test3_plugin_a.ml";
     travlangc.byte;
   }{
     module = "test3_plugin_b.ml";
     travlangc.byte;
   }{
     program = "test3_plugin.cma";
     flags = "-a";
     all_modules = "test3_plugin_a.cmo test3_plugin_b.cmo";
     travlangc.byte;
   }{
     program = "${test_build_directory}/test3.byte";
     libraries = "dynlink";
     all_modules = "test3_main.cmo";
     travlangc.byte;
     run;
   }
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   {
     module = "test3_main.ml";
     travlangopt.byte;
   }{
     module = "test3_plugin_a.ml";
     travlangopt.byte;
   }{
     module = "test3_plugin_b.ml";
     travlangopt.byte;
   }{
     program = "test3_plugin.cmxs";
     flags = "-shared";
     all_modules = "test3_plugin_a.cmx test3_plugin_b.cmx";
     travlangopt.byte;
   }{
     program = "${test_build_directory}/test3.exe";
     libraries = "dynlink";
     all_modules = "test3_main.cmx";
     travlangopt.byte;
     run;
   }
 }
*)

(* Check that one module in a shared library can refer to another module
   in the same shared library as long as the second module has already
   been loaded. *)

let () =
  if Dynlink.is_native then begin
    Dynlink.loadfile "test3_plugin.cmxs"
  end else begin
    Dynlink.loadfile "test3_plugin.cma"
  end
