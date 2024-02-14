(* TEST_BELOW
(* Blank lines added here to preserve locations. *)











*)

(*
  travlangc -c pr3918a.mli pr3918b.mli
  rm -f pr3918a.cmi
  travlangc -c pr3918c.ml
*)

open Pr3918b

let f x = (x : 'a vlist :> 'b vlist)
let f (x : 'a vlist) = (x : 'b vlist)

(* TEST
 readonly_files = "pr3918a.mli pr3918b.mli";
 setup-travlangc.byte-build-env;
 module = "pr3918a.mli";
 travlangc.byte;
 module = "pr3918b.mli";
 travlangc.byte;
 script = "rm -f pr3918a.cmi";
 script;
 {
   module = "pr3918c.ml";
   travlangc_byte_exit_status = "2";
   travlangc.byte;
 }{
   check-travlangc.byte-output;
 }
*)
