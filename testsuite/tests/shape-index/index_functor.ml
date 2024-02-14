(* TEST

flags = "-bin-annot -bin-annot-occurrences";
compile_only = "true";
setup-travlangc.byte-build-env;
all_modules = "index_functor.ml";
travlangc.byte;
check-travlangc.byte-output;

program = "-quiet -index -decls index_functor.cmt";
output = "out_objinfo";
travlangobjinfo;

check-program-output;
*)


module F (X :sig end ) = struct module M = X end
module N = F(struct end)
module O = N.M
include O
include N
