(* TEST
 include dynlink;
 readonly_files = "test6_plugin.ml test6_second_plugin.ml";
 libraries = "";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     module = "test6_main.ml";
     travlangc.byte;
   }{
     module = "test6_plugin.ml";
     travlangc.byte;
   }{
     module = "test6_second_plugin.ml";
     travlangc.byte;
   }{
     program = "${test_build_directory}/test6.byte";
     libraries = "dynlink";
     all_modules = "test6_main.cmo";
     travlangc.byte;
     run;
   }
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   {
     module = "test6_main.ml";
     travlangopt.byte;
   }{
     program = "test6_plugin.cmxs";
     flags = "-shared";
     all_modules = "test6_plugin.ml";
     travlangopt.byte;
   }{
     program = "test6_second_plugin.cmxs";
     flags = "-shared";
     all_modules = "test6_second_plugin.ml";
     travlangopt.byte;
   }{
     program = "${test_build_directory}/test6.exe";
     libraries = "dynlink";
     all_modules = "test6_main.cmx";
     travlangopt.byte;
     run;
   }
 }
*)

(* Check that a module in a loaded shared library whose initializer has not
   executed completely cannot be depended upon by another shared library being
   loaded. *)

let () =
  if Dynlink.is_native then
    Dynlink.loadfile "test6_plugin.cmxs"
  else
    Dynlink.loadfile "test6_plugin.cmo"
