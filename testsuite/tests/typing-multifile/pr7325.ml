(* TEST
 readonly_files = "a.ml b.ml c.ml";
 setup-travlangc.byte-build-env;
 module = "a.ml";
 travlangc.byte;
 module = "b.ml";
 travlangc.byte;
 script = "rm a.cmi";
 script;
 module = "c.ml";
 travlangc.byte;
 check-travlangc.byte-output;
*)
