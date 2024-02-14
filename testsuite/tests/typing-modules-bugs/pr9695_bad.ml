(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

module A = MissingModule
let () = let open A in x

(* TEST
 flags = " -w -a -no-alias-deps";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
