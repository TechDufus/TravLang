(* TEST
 readonly_files = "foo.ml gen_cached_cmi.ml input.ml";
 setup-travlangc.byte-build-env;
 module = "foo.ml";
 travlangc.byte;
 travlang_script_as_argument = "true";
 test_file = "gen_cached_cmi.ml";
 arguments = "cached_cmi.ml";
 travlang with travlangcommon;
 module = "";
 program = "${test_build_directory}/main.exe";
 libraries += "travlangbytecomp travlangtoplevel";
 all_modules = "foo.cmo cached_cmi.ml main.ml";
 travlangc.byte;
 set travlangLIB = "${travlangsrcdir}/stdlib";
 arguments = "input.ml";
 run;
 check-program-output;
*)

let () =
  (* Make sure it's no longer available on disk *)
  if Sys.file_exists "foo.cmi" then Sys.remove "foo.cmi";
  let module Persistent_signature = Persistent_env.Persistent_signature in
  let old_loader = !Persistent_signature.load in
  Persistent_signature.load := (fun ~allow_hidden ~unit_name ->
    match unit_name with
    | "Foo" ->
      Some { Persistent_signature.
             filename   = Sys.executable_name
           ; cmi        = Marshal.from_string Cached_cmi.foo 0
           ; visibility = Visible
           }
    | _ -> old_loader ~allow_hidden ~unit_name);
  Toploop.add_hook (function
      | Toploop.After_setup ->
          Toploop.toplevel_env :=
            Env.add_persistent_structure (Ident.create_persistent "Foo")
              !Toploop.toplevel_env
      | _ -> ());
  exit (Topmain.main ())
