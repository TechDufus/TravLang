(* TEST
 include dynlink;
 libraries = "";
 readonly_files = "config.ml b.ml";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     program = "plugin.cma";
     flags = "-a";
     all_modules = "config.ml b.ml";
     travlangc.byte;
   }{
     program = "${test_build_directory}/loader.byte";
     flags = "-linkall";
     include travlangcommon;
     libraries += "dynlink";
     all_modules = "loader.ml";
     travlangc.byte;
     arguments = "plugin.cma";
     exit_status = "2";
     run;
     reference = "${test_source_directory}/byte.reference";
     check-program-output;
   }
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   {
     program = "plugin.cmxs";
     flags = "-shared";
     all_modules = "config.ml b.ml";
     travlangopt.byte;
   }{
     program = "${test_build_directory}/loader.exe";
     flags = "-linkall";
     include travlangcommon;
     libraries += "dynlink";
     all_modules = "loader.ml";
     travlangopt.byte;
     arguments = "plugin.cmxs";
     exit_status = "2";
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
  | Dynlink.Error (Dynlink.Module_already_loaded "Config") -> exit 2
  | _ -> exit 1
