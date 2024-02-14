(* TEST
 reference = "${test_source_directory}/ellipses.reference";
 output = "ellipses.output";
 readonly_files = "${test_source_directory}/ellipses.input";
 script = "${travlangrun} ${travlangsrcdir}/tools/travlangtex -repo-root ${travlangsrcdir} ${readonly_files} -o ${output}";
 hasstr;
 hasunix;
 native-compiler;
 shared-libraries;
 script with unix, str;
 check-program-output;
*)
