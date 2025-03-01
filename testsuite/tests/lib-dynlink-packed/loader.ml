(* TEST
 include dynlink;
 libraries = "";
 readonly_files = "a.ml b.ml loader.ml";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     flags = "-for-pack Packed";
     module = "a.ml";
     travlangc.byte;
   }{
     flags = "-for-pack Packed";
     module = "b.ml";
     travlangc.byte;
   }{
     program = "packed.cmo";
     flags = "-pack";
     all_modules = "a.cmo b.cmo";
     travlangc.byte;
   }{
     program = "${test_build_directory}/loader.byte";
     flags = "-linkall";
     include travlangcommon;
     libraries += "dynlink";
     all_modules = "loader.ml";
     travlangc.byte;
     arguments = "packed.cmo";
     exit_status = "0";
     run;
     reference = "${test_source_directory}/byte.reference";
     check-program-output;
   }
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   {
     flags = "-for-pack Packed";
     module = "a.ml";
     travlangopt.byte;
   }{
     flags = "-for-pack Packed";
     module = "b.ml";
     travlangopt.byte;
   }{
     program = "packed.cmx";
     flags = "-pack";
     all_modules = "a.cmx b.cmx";
     travlangopt.byte;
   }{
     program = "plugin.cmxs";
     flags = "-shared";
     all_modules = "packed.cmx";
     travlangopt.byte;
   }{
     program = "${test_build_directory}/loader.exe";
     flags = "-linkall";
     include travlangcommon;
     libraries += "dynlink";
     all_modules = "loader.ml";
     travlangopt.byte;
     arguments = "plugin.cmxs";
     exit_status = "0";
     run;
     reference = "${test_source_directory}/native.reference";
     check-program-output;
   }
 }
*)
let () =
  try
    Dynlink.loadfile Sys.argv.(1)
  with
  | Dynlink.Error error ->
    prerr_endline (Dynlink.error_message error)
