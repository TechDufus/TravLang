(* TEST
 include dynlink;
 readonly_files = "abstract.mli abstract.ml static.ml client.ml main.ml";
 subdirectories = "sub";
 libraries = "";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   cwd = "sub";
   cd;
   module = "abstract.mli";
   travlangc.byte;
   module = "abstract.ml";
   travlangc.byte;
   cwd = "..";
   cd;
   module = "abstract.mli";
   travlangc.byte;
   module = "abstract.ml";
   travlangc.byte;
   module = "static.ml";
   travlangc.byte;
   module = "client.ml";
   travlangc.byte;
   module = "main.ml";
   travlangc.byte;
   program = "${test_build_directory}/main";
   libraries = "dynlink";
   module = "";
   all_modules = "abstract.cmo static.cmo main.cmo";
   travlangc.byte;
   exit_status = "2";
   run;
   check-program-output;
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   cwd = "sub";
   cd;
   module = "abstract.mli";
   travlangopt.byte;
   program = "abstract.cmxs";
   flags = "-shared";
   module = "";
   all_modules = "abstract.ml";
   travlangopt.byte;
   cwd = "..";
   cd;
   flags = "";
   module = "abstract.mli";
   travlangopt.byte;
   module = "abstract.ml";
   travlangopt.byte;
   module = "static.ml";
   travlangopt.byte;
   {
     program = "client.cmxs";
     flags = "-shared";
     module = "";
     all_modules = "client.ml";
     travlangopt.byte;
   }{
     module = "main.ml";
     travlangopt.byte;
     program = "${test_build_directory}/main_native";
     libraries = "dynlink";
     module = "";
     all_modules = "abstract.cmx static.cmx main.cmx";
     travlangopt.byte;
     exit_status = "2";
     run;
     check-program-output;
   }
 }
*)

(* PR#4229 *)

let () =
  let suffix =
    match Sys.backend_type with
    | Native -> "cmxs"
    | Bytecode -> "cmo"
    | Other _ -> assert false
  in
  try
    (* Dynlink.init (); *)  (* this function has been removed from the API *)
    Dynlink.loadfile ("client."^suffix); (* utilise abstract.suffix *)
    Dynlink.loadfile ("sub/abstract."^suffix);
    Dynlink.loadfile ("client."^suffix) (* utilise sub/abstract.suffix *)
  with
  | Dynlink.Error (Dynlink.Module_already_loaded "Abstract") -> exit 2
