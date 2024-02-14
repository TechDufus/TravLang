(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

let _ = () in 3;;

(**
       0 CONST0
       1 PUSHCONST3
       2 POP 1
       4 ATOM0
       5 SETGLOBAL T021-pushconst3
       7 STOP
**)
