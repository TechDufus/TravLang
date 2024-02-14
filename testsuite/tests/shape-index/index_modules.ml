(* TEST

flags = "-bin-annot -bin-annot-occurrences";
compile_only = "true";
setup-travlangc.byte-build-env;
all_modules = "index_modules.ml";
travlangc.byte;
check-travlangc.byte-output;

program = "-quiet -index -decls index_modules.cmt";
output = "out_objinfo";
travlangobjinfo;

check-program-output;
*)

(* Local modules: *)

let () =
  let module A = struct let x = 42 end in
  let open A in
  print_int (x + A.x)
