(* TEST
 modules = "lib.ml";
 {
   setup-travlangc.byte-build-env;
   all_modules = "main.ml";
   compile_only = "true";
   travlangc.byte;
   all_modules = "lib.ml";
   travlangc.byte;
   {
     all_modules = "lib.cmo main.cmo";
     compile_only = "false";
     travlangc_byte_exit_status = "2";
     travlangc.byte;
   }{
     all_modules = "lib.cmo main.cmo";
     compile_only = "false";
     travlangc_byte_exit_status = "2";
     flags = "-a";
     travlangc.byte;
  }{
     all_modules = "lib.cmo";
     compile_only = "false";
     travlangc_byte_exit_status = "2";
     travlangc.byte;
     check-travlangc.byte-output;
  }
}{
   setup-travlangopt.byte-build-env;
   all_modules = "main.ml";
   compile_only = "true";
   travlangopt.byte;
   all_modules = "lib.ml";
   travlangopt.byte;
   {
     all_modules = "lib.cmx main.cmx";
     compile_only = "false";
     travlangopt_byte_exit_status = "2";
     travlangopt.byte;
   }{
     all_modules = "lib.cmx main.cmx";
     compile_only = "false";
     travlangopt_byte_exit_status = "2";
     flags = "-a";
     travlangopt.byte;
  }{
     all_modules = "lib.cmx";
     compile_only = "false";
     travlangopt_byte_exit_status = "2";
     travlangopt.byte;
     check-travlangopt.byte-output;
  }
}
*)

(* Make sure travlangc and travlangopt print badly ordered dependencies only once.
   See issue #12074. We test with travlangc.byte only. *)

let value = ()
