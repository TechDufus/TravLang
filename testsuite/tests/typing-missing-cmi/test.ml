(* TEST
 readonly_files = "a.ml b.ml c.ml main.ml main_ok.ml";
 subdirectories = "subdir";
 setup-travlangc.byte-build-env;
 module = "subdir/m.ml";
 travlangc.byte;
 flags = "-I subdir";
 module = "a.ml";
 travlangc.byte;
 module = "b.ml";
 travlangc.byte;
 module = "c.ml";
 travlangc.byte;
 flags = "";
 module = "main_ok.ml";
 travlangc.byte;
 module = "main.ml";
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 check-travlangc.byte-output;
*)
