(* TEST
 modules = "aliases.ml external_for_pack.ml external.ml submodule.ml test.ml use_in_pack.ml";
 {
   program = "${test_build_directory}/test.byte";
   setup-travlangc.byte-build-env;
   module = "submodule.ml";
   flags = "-no-alias-deps";
   travlangc.byte;
   module = "aliases.ml";
   travlangc.byte;
   module = "external.mli";
   travlangc.byte;
   module = "external.ml";
   travlangc.byte;
   module = "external_for_pack.mli";
   travlangc.byte;
   module = "external_for_pack.ml";
   travlangc.byte;
   module = "test.ml";
   travlangc.byte;
   module = "";
   flags = "-a -no-alias-deps";
   all_modules = "submodule.cmo aliases.cmo external.cmo external_for_pack.cmo";
   program = "mylib.cma";
   travlangc.byte;
   flags = "-no-alias-deps -for-pack P";
   module = "use_in_pack.ml";
   travlangc.byte;
   module = "";
   program = "p.cmo";
   flags = "-no-alias-deps -pack";
   all_modules = "use_in_pack.cmo";
   travlangc.byte;
   program = "${test_build_directory}/test.byte";
   all_modules = "mylib.cma p.cmo test.cmo";
   flags = "-no-alias-deps";
   travlangc.byte;
   check-travlangc.byte-output;
   run;
   check-program-output;
 }{
   program = "${test_build_directory}/test.opt";
   setup-travlangopt.byte-build-env;
   module = "submodule.ml";
   flags = "-no-alias-deps";
   travlangopt.byte;
   module = "aliases.ml";
   travlangopt.byte;
   module = "external.mli";
   travlangopt.byte;
   module = "external.ml";
   travlangopt.byte;
   module = "external_for_pack.mli";
   travlangopt.byte;
   module = "external_for_pack.ml";
   travlangopt.byte;
   module = "test.ml";
   travlangopt.byte;
   module = "";
   flags = "-no-alias-deps -a";
   all_modules = "submodule.cmx aliases.cmx external.cmx external_for_pack.cmx";
   program = "mylib.cmxa";
   travlangopt.byte;
   flags = "-no-alias-deps -for-pack P";
   module = "use_in_pack.ml";
   travlangopt.byte;
   module = "";
   program = "p.cmx";
   flags = "-no-alias-deps -pack";
   all_modules = "use_in_pack.cmx";
   travlangopt.byte;
   program = "${test_build_directory}/test.opt";
   all_modules = "mylib.cmxa p.cmx test.cmx";
   flags = "-no-alias-deps";
   travlangopt.byte;
   check-travlangopt.byte-output;
   run;
   check-program-output;
 }
*)

include Aliases.Submodule.M
let _, _ = External.frexp 3.
