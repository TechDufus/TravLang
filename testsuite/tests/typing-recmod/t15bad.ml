(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

(* Bad - PR 4512 *)
module type S' = sig type t = int end
module rec M : S' with type t = M.t = struct type t = M.t end;;

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
