(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

include struct
  let foo `Test = ()
  let wrap f `Test = f
  let bar = wrap ()
end

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
