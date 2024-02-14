(* TEST
 flags = "-i -annot";
 compile_only = "true";
 script = "sh ${test_source_directory}/check-annot.sh typeonly";
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

(* Check that .annot files are emitted in case of type-only compilation. *)
let a = 3
let b = float a
