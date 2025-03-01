(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

open Lib;;
let x = Bytes.of_string "foo" in
Bytes.set x 2 'x';
if Bytes.get x 2 <> 'x' then raise Not_found
;;

(**
       0 CONSTINT 42
       2 PUSHACC0
       3 MAKEBLOCK1 0
       5 POP 1
       7 SETGLOBAL Lib
       9 GETGLOBAL "foo"
      11 PUSHCONSTINT 120
      13 PUSHCONST2
      14 PUSHACC2
      15 SETSTRINGCHAR
      16 CONSTINT 120
      18 PUSHCONST2
      19 PUSHACC2
      20 GETSTRINGCHAR
      21 NEQ
      22 BRANCHIFNOT 29
      24 GETGLOBAL Not_found
      26 MAKEBLOCK1 0
      28 RAISE
      29 POP 1
      31 ATOM0
      32 SETGLOBAL T121-setstringchar
      34 STOP
**)
