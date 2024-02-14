(* TEST
 subdirectories = "dir1 dir2";
 setup-travlangc.byte-build-env;
 commandline = "-depend -slash -I dir1 -I dir2 a.ml";
 travlangc.byte;
 compiler_reference = "${test_source_directory}/a.reference";
 check-travlangc.byte-output;
*)

include B
include C
