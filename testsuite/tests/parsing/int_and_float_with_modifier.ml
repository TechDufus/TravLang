(* TEST_BELOW
Filler_text_added_
to_preserve_locations_while_tran
slating_from_old_syntax__Filler_
text_added_to_pre
serve_locations_while_translati
*)

let int_with_custom_modifier =
  1234567890_1234567890_1234567890_1234567890_1234567890z
let float_with_custom_modifier =
  1234567890_1234567890_1234567890_1234567890_1234567890.z

let int32     = 1234l
let int64     = 1234L
let nativeint = 1234n

let hex_without_modifier = 0x32f
let hex_with_modifier    = 0x32g

let float_without_modifer = 1.2e3
let float_with_modifer    = 1.2g

(* TEST
 flags = "-dparsetree";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
