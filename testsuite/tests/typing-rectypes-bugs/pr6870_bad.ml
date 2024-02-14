(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

module type T = sig type 'a t end
module Fix (T : T) = struct type r = ('r T.t as 'r) end

(* TEST
 flags = " -w -a -rectypes ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
