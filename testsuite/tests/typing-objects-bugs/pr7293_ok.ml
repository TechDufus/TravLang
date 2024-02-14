(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

type t = T : t
type s = T

class c = object (self : 'self)

  method foo : s -> 'self = function
    | T -> self#bar ()

  method bar : unit -> 'self = fun () -> self

end
