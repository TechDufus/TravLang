(* TEST_BELOW
(* Blank lines added here to preserve locations. *)



























*)

(* test for backtrace and stack unwinding with dynlink. *)
(* https://github.com/travlang-multicore/travlang-multicore/issues/440 *)
(* https://github.com/travlang-multicore/travlang-multicore/pull/499 *)

let ()  =
  Dynlink.allow_unsafe_modules true;
  try
    Dynlink.loadfile "backtrace_dynlink_plugin.cmxs"
  with
  | Dynlink.Error err ->
     print_endline @@ Dynlink.error_message err;
     Printexc.print_backtrace stdout;
  | exn ->
     Printexc.to_string exn |> print_endline;
     print_endline "ERROR"

(* TEST
 include dynlink;
 readonly_files = "backtrace_dynlink_plugin.ml";
 libraries = "";
 shared-libraries;
 native-dynlink;
 setup-travlangopt.byte-build-env;
 {
   module = "backtrace_dynlink.ml";
   flags = "-g";
   travlangopt.byte;
 }{
   program = "backtrace_dynlink_plugin.cmxs";
   flags = "-shared -g";
   all_modules = "backtrace_dynlink_plugin.ml";
   travlangopt.byte;
 }{
   program = "${test_build_directory}/main.exe";
   libraries = "dynlink";
   all_modules = "backtrace_dynlink.cmx";
   travlangopt.byte;
   travlangrunparam += ",b=1";
   run;
   {
     no-flambda;
     check-program-output;
   }{
     reference = "${test_source_directory}/backtrace_dynlink.flambda.reference";
     flambda;
     check-program-output;
   }
 }
*)
