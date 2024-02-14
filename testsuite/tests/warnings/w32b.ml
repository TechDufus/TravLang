(* TEST_BELOW
(* Blank lines added here to preserve locations. *)







*)

(* Check that [t] is considered unused without an .mli file (see GPR#1358) *)
module Q (M : sig type t end) = struct end

(* TEST
 flags = "-w +A-70";
 setup-travlangc.byte-build-env;
 compile_only = "true";
 travlangc.byte;
 check-travlangc.byte-output;
*)
