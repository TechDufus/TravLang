(* TEST
 include dynlink;
 readonly_files = "test8_plugin_a.ml test8_plugin_b.ml test8_plugin_b.mli";
 libraries = "";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     module = "test8_main.ml";
     travlangc.byte;
   }{
     module = "test8_plugin_b.mli";
     travlangc.byte;
   }{
     module = "test8_plugin_a.ml";
     travlangc.byte;
   }{
     module = "test8_plugin_b.ml";
     travlangc.byte;
   }{
     program = "test8_plugin.cma";
     flags = "-a";
     all_modules = "test8_plugin_a.cmo test8_plugin_b.cmo";
     travlangc.byte;
   }{
     program = "${test_build_directory}/test8.byte";
     libraries = "dynlink";
     all_modules = "test8_main.cmo";
     travlangc.byte;
     run;
   }
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   {
     module = "test8_main.ml";
     travlangopt.byte;
   }{
     module = "test8_plugin_b.mli";
     travlangopt.byte;
   }{
     module = "test8_plugin_a.ml";
     travlangopt.byte;
   }{
     module = "test8_plugin_b.ml";
     travlangopt.byte;
   }{
     program = "test8_plugin.cmxs";
     flags = "-shared";
     all_modules = "test8_plugin_a.cmx test8_plugin_b.cmx";
     travlangopt.byte;
   }{
     program = "${test_build_directory}/test8.exe";
     libraries = "dynlink";
     all_modules = "test8_main.cmx";
     travlangopt.byte;
     run;
   }
 }
*)

(* Check that modules of a shared library can have interface-only
   dependencies to later modules in the same shared library. *)

let () =
  if Dynlink.is_native then begin
    Dynlink.loadfile "test8_plugin.cmxs"
  end else begin
    Dynlink.loadfile "test8_plugin.cma"
  end
