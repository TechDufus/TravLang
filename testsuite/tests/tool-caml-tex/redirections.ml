(* TEST
 reference = "${test_source_directory}/redirections.reference";
 output = "redirections.output";
 readonly_files = "${test_source_directory}/redirections.input";
 script = "${travlangrun} ${travlangsrcdir}/tools/travlangtex -repo-root ${travlangsrcdir} ${readonly_files} -o ${output}";
 hasstr;
 hasunix;
 native-compiler;
 {
   shared-libraries;
   script with unix, str;
   check-program-output;
 }{
   no-shared-libraries;
   script = "${travlangsrcdir}/tools/travlangtex -repo-root ${travlangsrcdir} ${readonly_files} -o ${output}";
   script with unix, str;
   check-program-output;
 }
*)
