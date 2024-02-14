(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

(* OK (t = int) *)
module rec A : sig type t = B.t end = struct type t = B.t end
       and B : sig type t = int end = struct type t = int end;;
