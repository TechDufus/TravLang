(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

module type FOO = sig type t end
module type BAR =
sig
  (* Works: module rec A : (sig include FOO with type t = < b:B.t > end) *)
  module rec A : (FOO with type t = < b:B.t >)
         and B : FOO
end
