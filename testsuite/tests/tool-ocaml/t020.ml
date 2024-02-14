(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

let _ = () in ();;

(**
       0 CONST0
       1 PUSHCONST0
       2 POP 1
       4 ATOM0
       5 SETGLOBAL T020
       7 STOP
**)
