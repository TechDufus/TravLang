(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

let should_reject =
  let table = Hashtbl.create 1 in
  fun x y -> Hashtbl.add table x y

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
