(* TEST
 flags = "-no-alias-deps -w -49 -c";
 setup-travlangc.byte-build-env;
 travlangc_byte_exit_status = "2";
 travlangc.byte;
*)
module Loop = Pr8810
