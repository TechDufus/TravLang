(* TEST_BELOW
Filler_text_added_to_pr
eserve_locatio
ns_while_translating_from_old_syntax__Filler_
text_added_to_preserve_locations_
while_translating_from_old_s
*)

(* we intentionally write ill-typed output;
   if `-stop-after parsing` was not supported properly,
   the test would fail with an error *)
val x : Module_that_does_not_exists.type_that_does_not_exists

(* TEST
 setup-travlangc.byte-build-env;
 flags = "-stop-after parsing -dparsetree";
 travlangc_byte_exit_status = "0";
 travlangc.byte;
 check-travlangc.byte-output;
*)
