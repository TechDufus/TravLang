(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

open Lib;;
if not (0 >= 0) then raise Not_found;;

(**
       0 CONSTINT 42
       2 PUSHACC0
       3 MAKEBLOCK1 0
       5 POP 1
       7 SETGLOBAL Lib
       9 CONST0
      10 PUSHCONST0
      11 GEINT
      12 BOOLNOT
      13 BRANCHIFNOT 20
      15 GETGLOBAL Not_found
      17 MAKEBLOCK1 0
      19 RAISE
      20 ATOM0
      21 SETGLOBAL T080-geint
      23 STOP
**)
