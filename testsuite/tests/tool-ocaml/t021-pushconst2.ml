(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

let _ = () in 2;;

(**
       0 CONST0
       1 PUSHCONST2
       2 POP 1
       4 ATOM0
       5 SETGLOBAL T021-pushconst2
       7 STOP
**)
