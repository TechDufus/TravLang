(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

Lib.x;;

(**
       0 CONSTINT 42
       2 PUSHACC0
       3 MAKEBLOCK1 0
       5 POP 1
       7 SETGLOBAL Lib
       9 GETGLOBALFIELD Lib, 0
      12 ATOM0
      13 SETGLOBAL T051-getglobalfield
      15 STOP
**)
