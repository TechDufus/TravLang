(* TEST_BELOW
(* Blank lines added here to preserve locations. *)







*)

let foo ~bar = ignore bar (* one label *)

let bar ~foo ~baz = ignore (foo, baz) (* two labels *)

let () = foo 2
let () = bar 4 2

(* TEST
 flags = "-w +A-70";
 setup-travlangc.byte-build-env;
 compile_only = "true";
 travlangc.byte;
 check-travlangc.byte-output;
*)
