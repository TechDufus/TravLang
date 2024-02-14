(* TEST
 readonly_files = "A.ml B.ml C.ml D.ml lib_impl.ml lib.mli Makefile.build Makefile.build2";
 set sources = "A.ml B.ml C.ml D.ml";
 set links = "LibA.ml LibB.ml LibC.ml LibD.ml";
 set stdlib = "-nostdlib -I ${travlangsrcdir}/stdlib";
 set travlangC = "${travlangrun} ${travlangc_byte} ${stdlib}";
 set travlangOPT = "${travlangrun} ${travlangopt_byte} ${stdlib}";
 {
   compiler_directory_suffix = ".depend.mk";
   compiler_output = "${test_build_directory}/depend.mk";
   setup-travlangc.byte-build-env;
   src = "A.ml";
   dst = "LibA.ml";
   copy;
   src = "B.ml";
   dst = "LibB.ml";
   copy;
   src = "C.ml";
   dst = "LibC.ml";
   copy;
   src = "D.ml";
   dst = "LibD.ml";
   copy;
   src = "lib_impl.ml";
   dst = "lib.ml";
   copy;
   commandline = "-depend -as-map lib.ml lib.mli";
   travlangc.byte;
   commandline = "-depend -map lib.ml -open Lib ${links}";
   travlangc.byte;
   compiler_reference = "${test_source_directory}/depend.mk.reference";
   check-travlangc.byte-output;
   hasunix;
   script = "rm -f ${links}";
   script;
   script = "${MAKE} -f Makefile.build byte";
   script;
   native-compiler;
   script = "${MAKE} -f Makefile.build opt";
   script;
 }{
   compiler_directory_suffix = ".depend.mk2";
   compiler_output = "${test_build_directory}/depend.mk2";
   setup-travlangc.byte-build-env;
   src = "A.ml";
   dst = "LibA.ml";
   copy;
   src = "B.ml";
   dst = "LibB.ml";
   copy;
   src = "C.ml";
   dst = "LibC.ml";
   copy;
   src = "D.ml";
   dst = "LibD.ml";
   copy;
   commandline = "-depend -map lib.mli -open Lib ${links}";
   travlangc.byte;
   compiler_reference = "${test_source_directory}/depend.mk2.reference";
   check-travlangc.byte-output;
   hasunix;
   script = "rm -f ${links}";
   script;
   script = "${MAKE} -f Makefile.build2 byte";
   script;
   native-compiler;
   script = "${MAKE} -f Makefile.build2 opt";
   script;
 }{
   compiler_directory_suffix = ".depend.mod";
   setup-travlangc.byte-build-env;
   src = "A.ml";
   dst = "LibA.ml";
   copy;
   src = "B.ml";
   dst = "LibB.ml";
   copy;
   src = "C.ml";
   dst = "LibC.ml";
   copy;
   src = "D.ml";
   dst = "LibD.ml";
   copy;
   src = "lib_impl.ml";
   dst = "lib.ml";
   copy;
   commandline = "-depend -as-map -modules lib.ml lib.mli";
   travlangc.byte;
   commandline = "-depend -modules -map lib.ml -open Lib ${links}";
   travlangc.byte;
   compiler_reference = "${test_source_directory}/depend.mod.reference";
   check-travlangc.byte-output;
 }{
   compiler_directory_suffix = ".depend.mod2";
   setup-travlangc.byte-build-env;
   src = "A.ml";
   dst = "LibA.ml";
   copy;
   src = "B.ml";
   dst = "LibB.ml";
   copy;
   src = "C.ml";
   dst = "LibC.ml";
   copy;
   src = "D.ml";
   dst = "LibD.ml";
   copy;
   commandline = "-depend -modules -map lib.mli ${links}";
   travlangc.byte;
   compiler_reference = "${test_source_directory}/depend.mod2.reference";
   check-travlangc.byte-output;
 }{
   compiler_directory_suffix = ".depend.mod3";
   setup-travlangc.byte-build-env;
   src = "A.ml";
   dst = "LibA.ml";
   copy;
   src = "B.ml";
   dst = "LibB.ml";
   copy;
   src = "C.ml";
   dst = "LibC.ml";
   copy;
   src = "D.ml";
   dst = "LibD.ml";
   copy;
   commandline = "-depend -modules -as-map -map lib.mli -open Lib ${links}";
   travlangc.byte;
   compiler_reference = "${test_source_directory}/depend.mod3.reference";
   check-travlangc.byte-output;
 }
*)

open Lib

let () = Printf.printf "B.g 3 = %d\n%!" (B.g 3)
