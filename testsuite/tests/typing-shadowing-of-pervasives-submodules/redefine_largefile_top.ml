(* TEST
 readonly_files = "largeFile.ml";
 setup-travlang-build-env;
 compile_only = "true";
 all_modules = "largeFile.ml";
 travlangc.byte;
 script = "mkdir -p inc";
 script;
 script = "mv largeFile.cmi largeFile.cmo inc/";
 script;
 travlang;
 check-travlang-output;
*)
#directory "inc";;
#load "largeFile.cmo";;
print_string LargeFile.message;;
