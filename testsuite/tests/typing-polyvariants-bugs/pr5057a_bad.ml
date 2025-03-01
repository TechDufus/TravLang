(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

(* This one should fail *)

let f flag =
  let module T = Set.Make(struct type t = int let compare = compare end) in
  let _ = match flag with `A -> 0 | `B r -> r in
  let _ = match flag with `A -> T.mem | `B r -> r in
  ()

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
