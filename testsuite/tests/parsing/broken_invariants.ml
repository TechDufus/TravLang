(* TEST_BELOW
(* Blank lines added here to preserve locations. *)







*)

let empty_tuple = [%tuple];;
let empty_record = [%record];;
let empty_apply = [%no_args f];;
let f = function [%record_with_functor_fields] -> ();;
[%%empty_let];;
[%%empty_type];;
module type s = sig
 [%%missing_rhs]
end;;

let x: [%empty_poly_binder] = 0;;

let f (x:[%empty_poly_binder]) = 0;;

let f x = (x:[%empty_poly_binder]);;
let g: int -> [%empty_poly_binder] = fun n x -> x;;

(* TEST
 readonly_files = "illegal_ppx.ml";
 setup-travlangc.byte-build-env;
 all_modules = "illegal_ppx.ml";
 program = "ppx.exe";
 travlangc.byte with travlangcommon;
 all_modules = "broken_invariants.ml";
 flags = "-ppx '${travlangrun} ${test_build_directory_prefix}/travlangc.byte/ppx.exe'";
 toplevel;
*)
