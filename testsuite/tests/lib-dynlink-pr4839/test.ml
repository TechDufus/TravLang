(* TEST
 include dynlink;
 libraries = "";
 subdirectories = "host plugin1 plugin2 plugin3 plugin4";
 shared-libraries;
 {
   setup-travlangc.byte-build-env;
   {
     cwd = "plugin1";
     cd;
   }{
     module = "api.mli";
     travlangc.byte;
   }{
     flags = "-for-pack Packed";
     module = "api.ml";
     travlangc.byte;
   }{
     program = "packed.cmo";
     flags = "-pack";
     all_modules = "api.cmo";
     travlangc.byte;
   }{
     program = "plugin.cma";
     flags = "-a";
     all_modules = "plugin.ml";
     travlangc.byte;
   }{
     cwd = "..";
     cd;
   }{
     cwd = "plugin2";
     cd;
   }{
     module = "api.mli";
     travlangc.byte;
   }{
     flags = "-for-pack Packed";
     module = "api.ml";
     travlangc.byte;
   }{
     program = "packed.cmo";
     flags = "-pack";
     all_modules = "api.cmo";
     travlangc.byte;
   }{
     program = "plugin.cma";
     flags = "-a";
     all_modules = "plugin.ml";
     travlangc.byte;
   }{
     cwd = "..";
     cd;
   }{
     cwd = "plugin3";
     cd;
   }{
     module = "api.mli";
     travlangc.byte;
   }{
     flags = "-for-pack Packed";
     module = "api.ml";
     travlangc.byte;
   }{
     program = "packed.cmo";
     flags = "-pack";
     all_modules = "api.cmo";
     travlangc.byte;
   }{
     program = "plugin.cma";
     flags = "-a";
     all_modules = "packed.cmo plugin.ml";
     travlangc.byte;
   }{
     cwd = "..";
     cd;
   }{
     cwd = "plugin4";
     cd;
   }{
     module = "api.mli";
     travlangc.byte;
   }{
     flags = "-for-pack Packed";
     module = "api.ml";
     travlangc.byte;
   }{
     program = "packed.cmo";
     flags = "-pack";
     all_modules = "api.cmo";
     travlangc.byte;
   }{
     program = "plugin.cma";
     flags = "-a";
     all_modules = "packed.cmo plugin.ml";
     travlangc.byte;
   }{
     cwd = "..";
     cd;
   }{
     cwd = "host";
     cd;
   }{
     module = "api.mli";
     travlangc.byte;
   }{
     flags = "-for-pack Packed";
     module = "api.ml";
     travlangc.byte;
   }{
     program = "packed.cmo";
     flags = "-pack";
     all_modules = "api.cmo";
     travlangc.byte;
   }{
     program = "./host.byt";
     libraries = "dynlink";
     all_modules = "packed.cmo host.ml";
     travlangc.byte;
     {
       arguments = "../plugin1/plugin.cma";
       output = "byte.plugin1.result";
       run;
       reference = "${test_source_directory}/byte.plugin1.reference";
       check-program-output;
     }{
       arguments = "../plugin2/plugin.cma";
       output = "byte.plugin2.result";
       run;
       reference = "${test_source_directory}/byte.plugin2.reference";
       check-program-output;
     }{
       arguments = "../plugin3/plugin.cma";
       output = "byte.plugin3.result";
       run;
       reference = "${test_source_directory}/byte.plugin3.reference";
       check-program-output;
     }{
       arguments = "../plugin4/plugin.cma";
       output = "byte.plugin4.result";
       run;
       reference = "${test_source_directory}/byte.plugin4.reference";
       check-program-output;
     }
   }{
     cwd = "..";
     cd;
   }
 }{
   native-dynlink;
   {
     setup-travlangopt.byte-build-env;
     {
       cwd = "plugin1";
       cd;
     }{
       module = "api.mli";
       travlangopt.byte;
     }{
       flags = "-for-pack Packed";
       module = "api.ml";
       travlangopt.byte;
     }{
       program = "packed.cmx";
       flags = "-pack";
       all_modules = "api.cmx";
       travlangopt.byte;
     }{
       program = "plugin.cmxs";
       flags = "-shared";
       all_modules = "plugin.ml";
       travlangopt.byte;
     }{
       cwd = "..";
       cd;
     }{
       cwd = "plugin2";
       cd;
     }{
       module = "api.mli";
       travlangopt.byte;
     }{
       flags = "-for-pack Packed";
       module = "api.ml";
       travlangopt.byte;
     }{
       program = "packed.cmx";
       flags = "-pack";
       all_modules = "api.cmx";
       travlangopt.byte;
     }{
       program = "plugin.cmxs";
       flags = "-shared";
       all_modules = "plugin.ml";
       travlangopt.byte;
     }
   }{
     cwd = "..";
     cd;
     {
       cwd = "plugin3";
       cd;
     }{
       module = "api.mli";
       travlangopt.byte;
     }{
       flags = "-for-pack Packed";
       module = "api.ml";
       travlangopt.byte;
     }{
       program = "packed.cmx";
       flags = "-pack";
       all_modules = "api.cmx";
       travlangopt.byte;
     }{
       program = "plugin.cmxs";
       flags = "-shared";
       all_modules = "packed.cmx plugin.ml";
       travlangopt.byte;
     }{
       cwd = "..";
       cd;
     }{
       cwd = "plugin4";
       cd;
     }{
       module = "api.mli";
       travlangopt.byte;
     }{
       flags = "-for-pack Packed";
       module = "api.ml";
       travlangopt.byte;
     }{
       program = "packed.cmx";
       flags = "-pack";
       all_modules = "api.cmx";
       travlangopt.byte;
     }{
       program = "plugin.cmxs";
       flags = "-shared";
       all_modules = "packed.cmx plugin.ml";
       travlangopt.byte;
     }{
       cwd = "..";
       cd;
     }{
       cwd = "host";
       cd;
     }{
       module = "api.mli";
       travlangopt.byte;
     }{
       flags = "-for-pack Packed";
       module = "api.ml";
       travlangopt.byte;
     }{
       program = "packed.cmx";
       flags = "-pack";
       all_modules = "api.cmx";
       travlangopt.byte;
     }{
       program = "./host.exe";
       libraries = "dynlink";
       all_modules = "packed.cmx host.ml";
       travlangopt.byte;
       {
         arguments = "../plugin1/plugin.cmxs";
         output = "native.plugin1.result";
         run;
         reference = "${test_source_directory}/native.plugin1.reference";
         check-program-output;
       }{
         arguments = "../plugin2/plugin.cmxs";
         output = "native.plugin2.result";
         run;
         reference = "${test_source_directory}/native.plugin2.reference";
         check-program-output;
       }{
         arguments = "../plugin3/plugin.cmxs";
         output = "native.plugin3.result";
         run;
         reference = "${test_source_directory}/native.plugin3.reference";
         check-program-output;
       }{
         arguments = "../plugin4/plugin.cmxs";
         output = "native.plugin4.result";
         run;
         reference = "${test_source_directory}/native.plugin4.reference";
         check-program-output;
       }
     }{
       cwd = "..";
       cd;
     }
   }
 }
*)
