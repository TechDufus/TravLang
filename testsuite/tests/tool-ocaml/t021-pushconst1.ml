(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

let _ = () in 1;;

(**
       0 CONST0
       1 PUSHCONST1
       2 POP 1
       4 ATOM0
       5 SETGLOBAL T021-pushconst1
       7 STOP
**)
