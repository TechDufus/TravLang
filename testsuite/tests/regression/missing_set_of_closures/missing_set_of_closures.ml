(* TEST
 readonly_files = "a.ml b.ml b2.ml";
 subdirectories = "dir";
 setup-travlangopt.byte-build-env;
 module = "a.ml";
 travlangopt.byte;
 module = "b.ml";
 travlangopt.byte;
 module = "b2.ml";
 travlangopt.byte;
 src = "b.cmx b.cmi b2.cmx b2.cmi";
 dst = "dir/";
 copy;
 cwd = "dir";
 cd;
 module = "c.ml";
 flags = "-w -58";
 travlangopt.byte;
 check-travlangopt.byte-output;
*)
