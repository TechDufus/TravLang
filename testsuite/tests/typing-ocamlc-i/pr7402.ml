(* TEST_BELOW
(* Blank lines added here to preserve locations. *)



*)

module M: sig type t val v:t end = struct
  type t = A
  let v = A
end

module F = struct
module M = struct
    let v = M.v
  end

  let v = M.v
end

(* TEST
 flags = "-i -w +63";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
