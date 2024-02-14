(* TEST
   readonly_files="foo.ml";
   setup-travlangc.byte-build-env;
   {
   include travlangcommon;
   program = "marshalled.byte";
   all_modules = "marshalled.ml";
   travlangc.byte;
   script = "./marshalled.byte";
   script;
   }
   {
   all_modules = "foo.marshalled.ml";
   travlangc_byte_exit_status = "2";
   travlangc.byte;
   check-travlangc.byte-output;
   }
*)

(* This is a repro case for #12697 *)

let () =
  let ast = Pparse.parse_implementation ~tool_name:"test" "foo.ml" in
  Pparse.write_ast Pparse.Structure "foo.marshalled.ml" ast
