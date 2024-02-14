(* TEST
 include dynlink;
 readonly_files = "test9_plugin.ml test9_second_plugin.ml test9_second_plugin.mli";
 libraries = "";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     module = "test9_second_plugin.mli";
     travlangc.byte;
   }{
     module = "test9_main.ml";
     travlangc.byte;
   }{
     module = "test9_plugin.ml";
     travlangc.byte;
   }{
     module = "test9_second_plugin.ml";
     travlangc.byte;
   }{
     program = "${test_build_directory}/test9.byte";
     libraries = "dynlink";
     all_modules = "test9_main.cmo";
     travlangc.byte;
     run;
   }
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   {
     module = "test9_second_plugin.mli";
     travlangopt.byte;
   }{
     module = "test9_main.ml";
     travlangopt.byte;
   }{
     program = "test9_plugin.cmxs";
     flags = "-shared";
     all_modules = "test9_plugin.ml";
     travlangopt.byte;
   }{
     program = "test9_second_plugin.cmxs";
     flags = "-shared";
     all_modules = "test9_second_plugin.ml";
     travlangopt.byte;
   }{
     program = "${test_build_directory}/test9.exe";
     libraries = "dynlink";
     all_modules = "test9_main.cmx";
     travlangopt.byte;
     run;
   }
 }
*)

(* Check that a shared library can depend on an interface-only module
   that is implemented by another shared library that is loaded
   later. *)

let () =
  if Dynlink.is_native then begin
    Dynlink.loadfile "test9_plugin.cmxs";
    Dynlink.loadfile "test9_second_plugin.cmxs"
  end else begin
    Dynlink.loadfile "test9_plugin.cmo";
    Dynlink.loadfile "test9_second_plugin.cmo"
  end
