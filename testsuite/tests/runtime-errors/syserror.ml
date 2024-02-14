(* TEST
 flags = "-w -a";
 {
   setup-travlangc.byte-build-env;
   travlangc.byte;
   exit_status = "2";
   run;
   {
     libunix;
     reference = "${test_source_directory}/syserror.unix.reference";
     check-program-output;
   }{
     libwin32unix;
     reference = "${test_source_directory}/syserror.win32.reference";
     check-program-output;
   }
 }{
   setup-travlangopt.byte-build-env;
   travlangopt.byte;
   exit_status = "2";
   run;
   {
     libunix;
     reference = "${test_source_directory}/syserror.unix.reference";
     check-program-output;
   }{
     libwin32unix;
     reference = "${test_source_directory}/syserror.win32.reference";
     check-program-output;
   }
 }
*)

let _ = Printexc.record_backtrace false

let channel = open_out "titi:/toto"
