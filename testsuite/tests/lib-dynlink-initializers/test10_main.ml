(* TEST_BELOW
(* Blank lines added here to preserve locations. *)





































*)

(* Check that a module in the main program whose initializer has not
   executed completely cannot be depended upon by a shared library being
   loaded. *)

let () =
  Printexc.record_backtrace true;
  try
    if Dynlink.is_native then begin
      Dynlink.loadfile "test10_plugin.cmxs"
    end else begin
      Dynlink.loadfile "test10_plugin.cmo"
    end
  with
  | Dynlink.Error (Dynlink.Library's_module_initializers_failed exn) ->
      Printf.eprintf "Error: %s\n%!" (Printexc.to_string exn);
      Printexc.print_backtrace stderr

(* TEST
 include dynlink;
 readonly_files = "test10_plugin.ml";
 flags += "-g";
 libraries = "";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     module = "test10_main.ml";
     travlangc.byte;
   }{
     module = "test10_plugin.ml";
     travlangc.byte;
   }{
     program = "${test_build_directory}/test10.byte";
     libraries = "dynlink";
     all_modules = "test10_main.cmo";
     travlangc.byte;
     run;
     reference = "${test_source_directory}/test10_main.byte.reference";
     check-program-output;
   }
 }{
   no-flambda;
   native-dynlink;
   setup-travlangopt.byte-build-env;
   {
     module = "test10_main.ml";
     travlangopt.byte;
   }{
     program = "test10_plugin.cmxs";
     flags = "-shared";
     all_modules = "test10_plugin.ml";
     travlangopt.byte;
   }{
     program = "${test_build_directory}/test10.exe";
     libraries = "dynlink";
     all_modules = "test10_main.cmx";
     travlangopt.byte;
     run;
     reference = "${test_source_directory}/test10_main.native.reference";
     check-program-output;
   }
 }
*)
