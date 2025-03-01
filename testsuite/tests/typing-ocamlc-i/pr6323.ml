(* TEST_BELOW
(* Blank lines added here to preserve locations. *)



*)

type 'a t = B of 'a t list

let rec foo f = function
  | B(v)::tl -> B(foo f v)::foo f tl
  | [] -> []

module DT = struct
  type 'a t = {bar : 'a}
  let p t = foo (fun x -> x) t
end

(* TEST
 flags = "-i -w +63";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
