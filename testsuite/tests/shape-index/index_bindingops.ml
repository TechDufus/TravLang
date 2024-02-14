(* TEST

flags = "-bin-annot -bin-annot-occurrences";
compile_only = "true";
setup-travlangc.byte-build-env;
all_modules = "index_bindingops.ml";
travlangc.byte;
check-travlangc.byte-output;

program = "-quiet -index -decls index_bindingops.cmt";
output = "out_objinfo";
travlangobjinfo;

check-program-output;
*)

let (let+) x f = Option.map f x

let (and+) x y =
  Option.bind x @@ fun x ->
  Option.map (fun y -> (x, y)) y

let minus_three =
  let+ foo = None
  and+ bar = None
  and+ man = None in
  foo + bar - man

let _ = (let+)
let _ = (and+)
