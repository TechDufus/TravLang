(* TEST
 flags = "-w +A-70";
 readonly_files = "module_without_cmx.mli";
 {
   setup-travlangc.byte-build-env;
   module = "module_without_cmx.mli";
   travlangc.byte;
   module = "w58.ml";
   travlangc.byte;
   check-travlangc.byte-output;
 }{
   setup-travlangopt.byte-build-env;
   module = "module_without_cmx.mli";
   travlangopt.byte;
   module = "w58.ml";
   travlangopt.byte;
   check-travlangopt.byte-output;
 }
*)

let () = print_endline (Module_without_cmx.id "Hello World")
