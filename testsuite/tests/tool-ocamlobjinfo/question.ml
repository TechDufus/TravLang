(* TEST
 shared-libraries;
 setup-travlangopt.byte-build-env;
 flags = "-shared";
 all_modules = "question.ml";
 program = "question.cmxs";
 travlangopt.byte;
 check-travlangopt.byte-output;
 travlangobjinfo;
 check-program-output;
*)

let answer = 42
