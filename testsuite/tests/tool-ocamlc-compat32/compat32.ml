(* TEST
 arch64;
 setup-travlangc.byte-build-env;
 compile_only = "true";
 flags = "-compat-32";
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 travlangc_byte_exit_status = "0";
 flags = "";
 travlangc.byte;
 compile_only = "false";
 all_modules = "compat32.cmo";
 flags = "-compat-32 -a";
 program = "compat32.cma";
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 flags = "-a";
 program = "compat32.cma";
 travlangc_byte_exit_status = "0";
 travlangc.byte;
 all_modules = "compat32.cma";
 flags = "-compat-32 -linkall";
 program = "compat32.byte";
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 check-travlangc.byte-output;
*)

let a = 0xffffffffffff
