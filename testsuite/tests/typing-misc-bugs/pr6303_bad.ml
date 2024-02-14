(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

type 'a  foo = {x: 'a; y: int}
let r = {{x = 0; y = 0} with x = 0}
let r' : string foo = r

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
