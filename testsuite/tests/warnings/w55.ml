(* TEST_BELOW
(* Blank lines added here to preserve locations. *)


















*)

let f = (fun x -> x + 1) [@inline never]

let g x = (f [@inlined]) x

let r = ref f

let i x = (!r [@inlined]) x

let j x y = x + y

let h x = (j [@inlined]) x

let a x =
  let b = x + 1 in
  fun y -> y + b

let b x y = (a [@inlined]) x y

let c x = x + 1 [@@inline never]
let d x = (c [@inlined]) x

let g' x = (f [@inlined hint]) x

let i' x = (!r [@inlined hint]) x

let h' x = (j [@inlined hint]) x

let b' x y = (a [@inlined hint]) x y

let d' x = (c [@inlined hint]) x

(* TEST
 flags = "-w +A-70";
 compile_only = "true";
 {
   setup-travlangc.byte-build-env;
   travlangc.byte;
   check-travlangc.byte-output;
 }{
   no-flambda;
   setup-travlangopt.byte-build-env;
   travlangopt.byte;
   check-travlangopt.byte-output;
 }{
   compiler_reference = "${test_source_directory}/w55.flambda.reference";
   flambda;
   setup-travlangopt.byte-build-env;
   travlangopt.byte;
   check-travlangopt.byte-output;
 }
*)
