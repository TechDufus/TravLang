(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

open Lib;;
try
  ignore (3 / 0);
  raise Not_found;
with Division_by_zero -> ()

(**
       0 CONSTINT 42
       2 PUSHACC0
       3 MAKEBLOCK1 0
       5 POP 1
       7 SETGLOBAL Lib
       9 PUSHTRAP 19
      11 CONST0
      12 PUSHCONST3
      13 DIVINT
      14 GETGLOBAL Not_found
      16 MAKEBLOCK1 0
      18 RAISE
      19 PUSHGETGLOBAL Division_by_zero
      21 PUSHACC1
      22 GETFIELD0
      23 EQ
      24 BRANCHIFNOT 29
      26 CONST0
      27 BRANCH 31
      29 ACC0
      30 RAISE
      31 POP 1
      33 ATOM0
      34 SETGLOBAL T110-divint-3
      36 STOP
**)
