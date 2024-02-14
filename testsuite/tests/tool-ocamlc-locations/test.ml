(* TEST
 readonly_files="trivpp.ml testloc.ml";

 setup-travlangc.byte-build-env;

 program="trivpp.byte";
 all_modules = "trivpp.ml";
 travlangc.byte;

 all_modules = "testloc.ml";
 flags = "-error-style contextual -stop-after typing -pp ${test_build_directory}/trivpp.byte";
 travlangc_byte_exit_status="2";
 travlangc.byte;
 check-travlangc.byte-output;
*)

(* This is a repro case for #12238. *)
