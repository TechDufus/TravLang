(* TEST

flags = "-bin-annot -bin-annot-occurrences";
compile_only = "true";
setup-travlangc.byte-build-env;
all_modules = "index_aliases.ml";
travlangc.byte;
check-travlangc.byte-output;

program = "-quiet -index -decls index_aliases.cmt";
output = "out_objinfo";
travlangobjinfo;

check-program-output;
*)


module A = struct type t end
module B = A

module F (X : sig type t end) = X
module F' = F
module C = F'(A)

module C' = F(B)
module D = C

module G = B
include G
