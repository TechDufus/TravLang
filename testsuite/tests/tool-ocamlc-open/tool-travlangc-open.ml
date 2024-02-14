(* TEST
 readonly_files = "a.ml b.ml";
 setup-travlangc.byte-build-env;
 module = "a.ml";
 travlangc.byte;
 module = "b.ml";
 flags = "-open A.M";
 travlangc.byte;
 check-travlangc.byte-output;
*)
