(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

open Lib;;
if (3 asr 1) <> 1 then raise Not_found;;

(**
       0 CONSTINT 42
       2 PUSHACC0
       3 MAKEBLOCK1 0
       5 POP 1
       7 SETGLOBAL Lib
       9 CONST1
      10 PUSHCONST1
      11 PUSHCONST3
      12 ASRINT
      13 NEQ
      14 BRANCHIFNOT 21
      16 GETGLOBAL Not_found
      18 MAKEBLOCK1 0
      20 RAISE
      21 ATOM0
      22 SETGLOBAL T110-asrint-2
      24 STOP
**)
