(* TEST

flags = "-bin-annot -bin-annot-occurrences";
compile_only = "true";
readonly_files = "index_labels.ml";
setup-travlangc.byte-build-env;
all_modules = "index_labels.ml";
travlangc.byte;
check-travlangc.byte-output;

program = "-quiet -index -decls index_labels.cmt";
output = "out_objinfo";
travlangobjinfo;

check-program-output;
*)

type t = { mutable a: int; b: string }

let x = { a = 42; b = "" }
let _y =
  x.a <- 32;
  x.a

let f = function
  | { a = 42; b } -> ()
  | _ -> ()
