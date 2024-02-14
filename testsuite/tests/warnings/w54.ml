(* TEST_BELOW
(* Blank lines added here to preserve locations. *)







*)

let f = (fun x -> x) [@inline] [@inline never]
let g = (fun x -> x) [@inline] [@something_else] [@travlang.inline]

let h x = (g [@inlined] [@travlang.inlined never]) x

let v = ((fun x -> x) [@inline] [@inlined]) 1 (* accepted *)

let i = ((fun x -> x) [@inline]) [@@inline]

(* TEST
 flags = "-w +A-70";
 setup-travlangc.byte-build-env;
 compile_only = "true";
 travlangc.byte;
 check-travlangc.byte-output;
*)
