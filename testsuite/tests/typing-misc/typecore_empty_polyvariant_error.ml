(* TEST
 readonly_files = "empty_ppx.ml";
 setup-travlangc.byte-build-env;
 all_modules = "empty_ppx.ml";
 program = "ppx.exe";
 travlangc.byte with travlangcommon;
 all_modules = "${test_file}";
 flags = "-ppx '${travlangrun} ${test_build_directory_prefix}/travlangc.byte/ppx.exe'";
 toplevel;
*)

type t = [%empty_polyvar];;
let f: 'a. t -> 'a = function #t -> . ;;
