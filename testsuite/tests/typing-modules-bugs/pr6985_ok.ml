(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

module Foo
 (Bar : sig type a = private [> `A ] end)
 (Baz : module type of struct include Bar end) =
struct
end
module Bazoinks = struct type a = [ `A ] end
module Bug = Foo(Bazoinks)(Bazoinks)
