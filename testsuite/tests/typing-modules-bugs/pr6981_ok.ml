(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

module type S =
sig
  type a
  type b
end
module Foo
    (Bar : S with type a = private [> `A])
    (Baz : S with type b = private < b : Bar.b ; .. >) =
struct
end
