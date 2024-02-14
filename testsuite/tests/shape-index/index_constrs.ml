(* TEST

flags = "-bin-annot -bin-annot-occurrences";
compile_only = "true";
readonly_files = "index_constrs.ml";
setup-travlangc.byte-build-env;
all_modules = "index_constrs.ml";
travlangc.byte;
check-travlangc.byte-output;

program = "-quiet -index -decls index_constrs.cmt";
output = "out_objinfo";
travlangobjinfo;

check-program-output;
*)

exception E
module M = struct
  exception F = E
end

type t = E

let x_ = E
let () = raise E
let f x = match x with
  | E -> ()
  | exception E -> ()

let _ = None
let _ = [%extension_constructor M.F]
