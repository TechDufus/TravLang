(* TEST
 include dynlink;
 readonly_files = "test7_interface_only.mli test7_plugin.ml";
 libraries = "";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     module = "test7_interface_only.mli";
     travlangc.byte;
   }{
     module = "test7_main.ml";
     travlangc.byte;
   }{
     module = "test7_plugin.ml";
     travlangc.byte;
   }{
     program = "${test_build_directory}/test7.byte";
     libraries = "dynlink";
     all_modules = "test7_main.cmo";
     travlangc.byte;
     run;
   }
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   {
     module = "test7_interface_only.mli";
     travlangopt.byte;
   }{
     module = "test7_main.ml";
     travlangopt.byte;
   }{
     program = "test7_plugin.cmxs";
     flags = "-shared";
     all_modules = "test7_plugin.ml";
     travlangopt.byte;
   }{
     program = "${test_build_directory}/test7.exe";
     libraries = "dynlink";
     all_modules = "test7_main.cmx";
     travlangopt.byte;
     run;
   }
 }
*)

(* Check that a shared library can depend on an interface-only module
   that is also depended on by modules in the main program *)

let f (x : Test7_interface_only.t) = x + 1 [@@inline never]

let () =
  if Dynlink.is_native then
    Dynlink.loadfile "test7_plugin.cmxs"
  else
    Dynlink.loadfile "test7_plugin.cmo"
