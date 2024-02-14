(* TEST
 readonly_files = "foo.mli bar.mli baz.ml";
 setup-travlangc.byte-build-env;
 module = "foo.mli";
 travlangc.byte;
 module = "bar.mli";
 travlangc.byte;
 script = "rm foo.cmi";
 script;
 flags = "-c -i";
 module = "baz.ml";
 travlangc_byte_exit_status = "0";
 travlangc.byte;
 check-travlangc.byte-output;
*)
