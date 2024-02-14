(* TEST
   setup-travlangc.byte-build-env;
   compile_only = "true";
   travlangc.byte;
   flags = "gpr12887.cmo";
   travlang_exit_status = "2";
   travlangrunparam = "b=0,v=0x0";
   travlang;
   check-travlang-output;
*)

let () = failwith "Print me"
