(* TEST
 set foo = "bar";
 flags += " -g ";
 travlangdebug_script = "${test_source_directory}/input_script";
 debugger;
 shared-libraries;
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
 travlangdebug;
 check-program-output;
*)

print_endline Sys.argv.(1);;
print_endline (Sys.getenv "foo");;
