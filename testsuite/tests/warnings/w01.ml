(* TEST_BELOW
(* Blank lines added here to preserve locations. *)







*)

(* C *)

let foo = ( *);;


(* F *)

let f x y = x;;
f 1; f 1;;


(* M *)

(* duh *)


(* P *)

let 1 = 1;;


(* S *)

1; 1;;


(* U *)

match 1 with
| 1 -> ()
| 1 -> ()
| _ -> ()
;;


(* V *)

(* re-duh *)


(* X *)

(* re-re *)

(* TEST
 flags = "-w +A-70";
 setup-travlangc.byte-build-env;
 compile_only = "true";
 travlangc.byte;
 check-travlangc.byte-output;
*)
