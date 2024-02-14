(* TEST
 native-compiler;
 setup-travlangopt.byte-build-env;
 flags = "-save-ir-after scheduling";
 travlangopt_byte_exit_status = "0";
 travlangopt.byte;
 script = "touch empty.ml";
 script;
 flags = "-S check_for_pack.cmir-linear -for-pack foo";
 module = "empty.ml";
 travlangopt_byte_exit_status = "2";
 travlangopt.byte;
 check-travlangopt.byte-output;
*)

let foo f x =
  if x > 0 then x * 7 else f x

let bar x y = x + y
