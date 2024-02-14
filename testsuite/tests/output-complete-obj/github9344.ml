(* TEST
 use_runtime = "false";
 setup-travlangc.byte-build-env;
 flags = "-w -a -output-complete-exe -ccopt -I${travlangsrcdir}/runtime";
 program = "github9344";
 travlangc.byte;
 program = "sh ${test_source_directory}/github9344.sh";
 run;
 check-program-output;
*)

raise Not_found
