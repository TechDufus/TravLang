(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

module M (T:sig type t end)
 = struct type t = private { t : T.t } end
module P
 = struct
       module T = struct type t end
       module R = M(T)
 end
