(* TEST
 include tool-travlang-lib;
 flags = "-w -a";
 travlang_script_as_argument = "true";
 setup-travlang-build-env;
 travlang;
*)

type t = {
  mutable a : int;
  mutable b : int;
};;

{ a = 0; b = 0 };;

(**
       0 CONST0
       1 PUSHCONST0
       2 MAKEBLOCK2 0
       4 ATOM0
       5 SETGLOBAL T040-makeblock2
       7 STOP
**)
