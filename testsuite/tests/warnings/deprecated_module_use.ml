(* TEST_BELOW
(* Blank lines added here to preserve locations. *)













*)

open Deprecated_module

type s = M.t

open M
let _ = x

(* TEST
 modules = "deprecated_module.mli deprecated_module.ml";
 setup-travlangc.byte-build-env;
 flags = "-w -a";
 module = "deprecated_module.mli";
 travlangc.byte;
 module = "deprecated_module.ml";
 travlangc.byte;
 flags = "-w +A-70";
 module = "deprecated_module_use.ml";
 travlangc.byte;
 check-travlangc.byte-output;
*)
