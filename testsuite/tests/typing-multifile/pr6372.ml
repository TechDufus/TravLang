(* TEST
 readonly_files = "d.mli e.ml";
 setup-travlangc.byte-build-env;
 module = "d.mli";
 travlangc.byte;
 module = "e.ml";
 travlangc.byte;
 check-travlangc.byte-output;
*)
