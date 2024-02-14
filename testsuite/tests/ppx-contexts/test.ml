(* TEST
 readonly_files = "myppx.ml";
 include travlangcommon;
 setup-travlangc.byte-build-env;
 program = "${test_build_directory}/myppx.exe";
 all_modules = "myppx.ml";
 travlangc.byte;
 module = "test.ml";
 flags = "-thread -I ${test_build_directory} -open List -rectypes -principal -alias-deps -unboxed-types -ppx ${program}";
 travlangc.byte;
 module = "test.ml";
 flags = "-g -no-alias-deps -no-unboxed-types -ppx ${program}";
 travlangc.byte;
 check-travlangc.byte-output;
*)

(* empty *)
