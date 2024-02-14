(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 travlang_exit_status = "2";
 setup-travlang-build-env;
 travlang;
*)

open Lib;;
raise End_of_file;;

(**
       0 CONSTINT 42
       2 PUSHACC0
       3 MAKEBLOCK1 0
       5 POP 1
       7 SETGLOBAL Lib
       9 GETGLOBAL End_of_file
      11 MAKEBLOCK1 0
      13 RAISE
      14 SETGLOBAL T060-raise
      16 STOP
**)
