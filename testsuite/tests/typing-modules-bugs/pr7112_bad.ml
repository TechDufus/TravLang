(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

module A = struct module type S module S = struct end end
module F (_ : sig end) = struct module type S module S = A.S end
module M = struct end
module N = M
module G (X : F(N).S) : A.S = X

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
