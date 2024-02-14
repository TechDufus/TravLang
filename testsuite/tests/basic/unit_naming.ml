(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

print_int Camlcase.answer

(* TEST
 modules = "camlCase.ml";
 setup-travlangc.byte-build-env;
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 check-travlangc.byte-output;
*)
