(* TEST
 include dynlink;
 readonly_files = "test1_inited_second.ml test1_plugin.ml";
 libraries = "";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     module = "test1_main.ml";
     travlangc.byte;
   }{
     module = "test1_inited_second.ml";
     travlangc.byte;
   }{
     module = "test1_plugin.ml";
     travlangc.byte;
   }{
     program = "${test_build_directory}/test1.byte";
     libraries = "dynlink";
     all_modules = "test1_main.cmo test1_inited_second.cmo";
     travlangc.byte;
     run;
   }
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   {
     module = "test1_main.ml";
     travlangopt.byte;
   }{
     module = "test1_inited_second.ml";
     travlangopt.byte;
   }{
     program = "test1_plugin.cmxs";
     flags = "-shared";
     all_modules = "test1_plugin.ml";
     travlangopt.byte;
   }{
     program = "${test_build_directory}/test1.exe";
     libraries = "dynlink";
     all_modules = "test1_main.cmx test1_inited_second.cmx";
     travlangopt.byte;
     run;
   }
 }
*)

(* Check that a module in the main program whose initializer has not
   executed completely cannot be depended upon by a shared library being
   loaded. *)

let f x = x + 1 [@@inline never]

let () =
  try
    if Dynlink.is_native then begin
      Dynlink.loadfile "test1_plugin.cmxs"
    end else begin
      Dynlink.loadfile "test1_plugin.cmo"
    end;
    assert false
  with
  | Dynlink.Error (
      Dynlink.Linking_error (_,
        Dynlink.Uninitialized_global "Test1_inited_second")) -> ()
