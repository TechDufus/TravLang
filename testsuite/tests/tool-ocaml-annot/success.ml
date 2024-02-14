(* TEST
 flags = "-annot";
 script = "sh ${test_source_directory}/check-annot.sh success";
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

(* Check that .annot files are emitted in case of regular successful
   compilation. *)
let a = 3
let b = float a
