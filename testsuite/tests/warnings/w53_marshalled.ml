(* TEST
   readonly_files = "marshall_for_w53.ml w53.ml";
   setup-travlangc.byte-build-env;
   all_modules = "marshall_for_w53.ml";
   program = "${test_build_directory}/marshall_for_w53.exe";
   flags = "-w +A-22-27-32-60-67-70-71-72";
   travlangc.byte with travlangcommon;
   run;
   all_modules = "w53.marshalled.ml";
   travlangc.byte;
   compiler_reference = "${test_source_directory}/w53.compilers.reference";
   check-travlangc.byte-output;
*)

(* This tests that warning 53 happen appropriately when dealing with marshalled
   ASTs.  It does that by marshalling `w53.ml` to disk and then passing the
   marshalled ast to the compiler. *)
