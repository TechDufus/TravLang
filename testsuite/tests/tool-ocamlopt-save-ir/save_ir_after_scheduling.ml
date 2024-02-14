(* TEST
 native-compiler;
 setup-travlangopt.byte-build-env;
 flags = "-save-ir-after scheduling -S";
 travlangopt.byte;
 check-travlangopt.byte-output;
 script = "sh ${test_source_directory}/save_ir_after_scheduling.sh";
 script;
*)

let foo f x =
  if x > 0 then x * 7 else f x

let bar x y = x + y
