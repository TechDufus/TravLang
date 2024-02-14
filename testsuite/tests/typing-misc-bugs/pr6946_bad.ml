(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

external foo : int = "%ignore";;
let _ = foo ();;

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
