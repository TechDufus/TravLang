(* TEST_BELOW
(* Blank lines added here to preserve locations. *)



*)

type t = A
module B =
struct
  type t = B
  let f A = B
end

(* TEST
 flags = "-i -w +63";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
