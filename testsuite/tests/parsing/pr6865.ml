(* TEST_BELOW
Filler_text_added_
to_preserve_locations_while_tran
slating_from_old_syntax__Filler_
text_added_to_pre
serve_locations_while_translati
*)

let%foo x = 42
let%foo _ = () and _ = ()
let%foo _ = ()

(* TEST
 flags = "-dparsetree";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
