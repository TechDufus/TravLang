(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

module type S = sig
 type +'a t

 val foo : [`A] t -> unit
 val bar : [< `A | `B] t -> unit
end

module Make(T : S) = struct
 let f x =
   T.foo x;
   T.bar x;
   (x :> [`A | `C] T.t)
end
