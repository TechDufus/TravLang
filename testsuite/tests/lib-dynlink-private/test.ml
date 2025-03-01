(* TEST
 include dynlink;
 libraries = "";
 readonly_files = "sheep.mli sheep.ml pig.mli";
 subdirectories = "plugin1 plugin2 plugin2b plugin2c plugin3 plugin4 plugin5 plugin6";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   module = "sheep.mli";
   travlangc.byte;
   module = "sheep.ml";
   travlangc.byte;
   module = "pig.mli";
   travlangc.byte;
   module = "test.ml";
   travlangc.byte;
   module = "plugin1/sheep.mli";
   travlangc.byte;
   flags = "-I plugin1";
   module = "plugin1/sheep.ml";
   travlangc.byte;
   flags = "";
   module = "plugin2/cow.mli";
   travlangc.byte;
   flags = "-I plugin2";
   module = "plugin2/cow.ml";
   travlangc.byte;
   flags = "";
   module = "plugin2b/cow.mli";
   travlangc.byte;
   flags = "-I plugin2b";
   module = "plugin2b/cow.ml";
   travlangc.byte;
   flags = "";
   module = "plugin2c/cow.mli";
   travlangc.byte;
   flags = "-I plugin2c";
   module = "plugin2c/cow.ml";
   travlangc.byte;
   flags = "";
   module = "plugin3/pig.mli";
   travlangc.byte;
   flags = "-I plugin3";
   module = "plugin3/pig.ml";
   travlangc.byte;
   flags = "";
   module = "plugin4/chicken.mli";
   travlangc.byte;
   flags = "-I plugin4";
   module = "plugin4/chicken.ml";
   travlangc.byte;
   flags = "";
   module = "plugin5/chicken.mli";
   travlangc.byte;
   flags = "-I plugin5";
   module = "plugin5/chicken.ml";
   travlangc.byte;
   flags = "";
   module = "plugin6/pheasant.mli";
   travlangc.byte;
   flags = "-I plugin6";
   module = "plugin6/pheasant.ml";
   travlangc.byte;
   flags = "";
   module = "plugin6/partridge.mli";
   travlangc.byte;
   flags = "-I plugin6";
   module = "plugin6/partridge.ml";
   travlangc.byte;
   flags = "";
   program = "./test.byte.exe";
   libraries = "dynlink";
   all_modules = "sheep.cmo test.cmo";
   module = "";
   travlangc.byte;
   run;
 }{
   native-dynlink;
   setup-travlangopt.byte-build-env;
   module = "sheep.mli";
   travlangopt.byte;
   module = "sheep.ml";
   travlangopt.byte;
   module = "pig.mli";
   travlangopt.byte;
   module = "test.ml";
   travlangopt.byte;
   flags = "";
   module = "plugin1/sheep.mli";
   travlangopt.byte;
   program = "plugin1/sheep.cmxs";
   flags = "-I plugin1 -shared";
   module = "";
   all_modules = "plugin1/sheep.ml";
   travlangopt.byte;
   flags = "";
   module = "plugin2/cow.mli";
   travlangopt.byte;
   program = "plugin2/cow.cmxs";
   flags = "-I plugin2 -shared";
   module = "";
   all_modules = "plugin2/cow.ml";
   travlangopt.byte;
   flags = "";
   module = "plugin2b/cow.mli";
   travlangopt.byte;
   program = "plugin2b/cow.cmxs";
   flags = "-I plugin2b -shared";
   module = "";
   all_modules = "plugin2b/cow.ml";
   travlangopt.byte;
   flags = "";
   module = "plugin2c/cow.mli";
   travlangopt.byte;
   program = "plugin2c/cow.cmxs";
   flags = "-I plugin2c -shared";
   module = "";
   all_modules = "plugin2c/cow.ml";
   travlangopt.byte;
   flags = "";
   module = "plugin3/pig.mli";
   travlangopt.byte;
   program = "plugin3/pig.cmxs";
   flags = "-I plugin3 -shared";
   module = "";
   all_modules = "plugin3/pig.ml";
   travlangopt.byte;
   flags = "";
   module = "plugin4/chicken.mli";
   travlangopt.byte;
   program = "plugin4/chicken.cmxs";
   flags = "-I plugin4 -shared";
   module = "";
   all_modules = "plugin4/chicken.ml";
   travlangopt.byte;
   flags = "";
   module = "plugin5/chicken.mli";
   travlangopt.byte;
   program = "plugin5/chicken.cmxs";
   flags = "-I plugin5 -shared";
   module = "";
   all_modules = "plugin5/chicken.ml";
   travlangopt.byte;
   flags = "";
   module = "plugin6/pheasant.mli";
   travlangopt.byte;
   program = "plugin6/pheasant.cmxs";
   flags = "-I plugin6 -shared";
   module = "";
   all_modules = "plugin6/pheasant.ml";
   travlangopt.byte;
   flags = "";
   module = "plugin6/partridge.mli";
   travlangopt.byte;
   program = "plugin6/partridge.cmxs";
   flags = "-I plugin6 -shared";
   module = "";
   all_modules = "plugin6/partridge.ml";
   travlangopt.byte;
   flags = "";
   program = "./test.opt.exe";
   libraries = "dynlink";
   all_modules = "sheep.cmx test.cmx";
   travlangopt.byte;
   run;
 }
*)

let () = Sheep.baa Sheep.s (* Use Sheep module *)
let _ = fun (x : Pig.t) -> x (* Reference Pig module *)

(* Test that a privately loaded module cannot have the same name as a
   module in the program. *)
let test_sheep () =
  match
    if Dynlink.is_native then
      Dynlink.loadfile_private "plugin1/sheep.cmxs"
    else
      Dynlink.loadfile_private "plugin1/sheep.cmo"
  with
  | () -> assert false
  | exception Dynlink.Error (
      Dynlink.Module_already_loaded "Sheep") -> ()

(* Test repeated loading of a privately-loaded module. *)
let test_cow_repeated () =
  if Dynlink.is_native then
    Dynlink.loadfile_private "plugin2/cow.cmxs"
  else
    Dynlink.loadfile_private "plugin2/cow.cmo"

(* Test that a privately loaded module can have the same name as a
   previous privately loaded module, in the case where the interfaces are
   the same, but the implementations differ. *)
let test_cow_same_name_same_mli () =
  if Dynlink.is_native then
    Dynlink.loadfile_private "plugin2b/cow.cmxs"
  else
    Dynlink.loadfile_private "plugin2b/cow.cmo"

(* Test that a privately loaded module can have the same name as a
   previous privately loaded module, in the case where neither the interfaces
   nor the implementations are the same. *)
let test_cow_same_name_different_mli () =
  if Dynlink.is_native then
    Dynlink.loadfile_private "plugin2c/cow.cmxs"
  else
    Dynlink.loadfile_private "plugin2c/cow.cmo"

(* Test that a privately loaded module cannot have the same name as an
   interface depended on by modules the program. *)
let test_pig () =
  match
    if Dynlink.is_native then
      Dynlink.loadfile_private "plugin3/pig.cmxs"
    else
      Dynlink.loadfile_private "plugin3/pig.cmo"
  with
  | () -> assert false
  | exception Dynlink.Error (
      Dynlink.Private_library_cannot_implement_interface "Pig") -> ()

(* Test that a privately loaded module can recursively load a module of
   the same name. *)
let test_chicken () =
  if Dynlink.is_native then
    Dynlink.loadfile_private "plugin4/chicken.cmxs"
  else
    Dynlink.loadfile_private "plugin4/chicken.cmo"

(* Test that a public load of a module M inside a privately-loaded module,
   followed by a public load of M, causes an error. *)
let test_pheasant () =
  begin
    if Dynlink.is_native then
      Dynlink.loadfile_private "plugin6/pheasant.cmxs"
    else
      Dynlink.loadfile_private "plugin6/pheasant.cmo"
  end;
  match
    if Dynlink.is_native then
      Dynlink.loadfile "plugin6/partridge.cmxs"
    else
      Dynlink.loadfile "plugin6/partridge.cmo"
  with
  | () -> assert false
  | exception Dynlink.Error (
      Dynlink.Module_already_loaded "Partridge") -> ()

let debug_runtime = String.equal (Sys.runtime_variant ()) "d"

(* test_cow_repeated is disabled when running with the debug runtime.
   Reloading multiple times a module can cause an already initialized block
   to be overwritten. See https://github.com/travlang/travlang/issues/11016 *)
let () =
  test_sheep ();
  if (not debug_runtime) then (
    test_cow_repeated ();
    test_cow_repeated ()
  );
  test_cow_same_name_same_mli ();
  test_cow_same_name_different_mli ();
  test_pig ();
  test_chicken ();
  test_pheasant ()
