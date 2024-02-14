(* TEST_BELOW
(* Blank lines added here to preserve locations. *)







*)

module A : sig end = struct
  module L = List

  module X1 = struct end

  module Y1 = X1
end

(* TEST
 flags = "-w +A-70";
 setup-travlangc.byte-build-env;
 compile_only = "true";
 travlangc.byte;
 check-travlangc.byte-output;
*)
