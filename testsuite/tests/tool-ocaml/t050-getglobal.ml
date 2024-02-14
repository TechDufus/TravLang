(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

[1];;

(**
       0 GETGLOBAL <0>(1, 0)
       2 ATOM0
       3 SETGLOBAL T050-getglobal
       5 STOP
**)
