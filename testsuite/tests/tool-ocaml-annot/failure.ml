(* TEST
 flags = "-annot";
 script = "sh ${test_source_directory}/check-annot.sh failure";
 travlangc_byte_exit_status = "2";
 travlangopt_byte_exit_status = "2";
 {
   setup-travlangc.byte-build-env;
   travlangc.byte;
   script;
 }{
   setup-travlangopt.byte-build-env;
   travlangopt.byte;
   script;
 }
*)

(* Check that .annot files are emitted in case of failed compilation. *)
let a = 3
let b = a +. 1
