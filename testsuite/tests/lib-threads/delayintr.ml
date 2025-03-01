(* TEST
 include systhreads;
 readonly_files = "sigint.c";
 hassysthreads;
 libunix; (* excludes mingw32/64 and msvc32/64 *)
 {
   program = "${test_build_directory}/delayintr.byte";
   setup-travlangc.byte-build-env;
   program = "sigint";
   all_modules = "sigint.c";
   travlangc.byte;
   program = "${test_build_directory}/delayintr.byte";
   all_modules = "delayintr.ml";
   travlangc.byte;
   check-travlangc.byte-output;
   run;
   check-program-output;
 }{
   program = "${test_build_directory}/delayintr.opt";
   setup-travlangopt.byte-build-env;
   program = "sigint";
   all_modules = "sigint.c";
   travlangopt.byte;
   program = "${test_build_directory}/delayintr.opt";
   all_modules = "delayintr.ml";
   travlangopt.byte;
   check-travlangopt.byte-output;
   run;
   check-program-output;
 }
*)

(* Regression test for MPR#7903 *)

let () =
  let start = Unix.gettimeofday() in
  let sighandler _ =
    let now = Unix.gettimeofday() in
    if now -. start <= 20. then begin
      print_string "Received signal early\n"; exit 0
    end else begin
      print_string "Received signal late\n"; exit 2
    end in
  Sys.set_signal Sys.sigint (Sys.Signal_handle sighandler);
  Thread.delay 30.;
  print_string "No signal received\n"; exit 4
