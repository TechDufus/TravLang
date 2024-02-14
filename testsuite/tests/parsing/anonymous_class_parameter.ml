(* TEST
 flags = "-i";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

(* This test is valid travlang code.
   It uses an anonymous type variable as a formal parameter in a class
   declaration. This used to be rejected by the parser, even though the
   printer (travlangc -i) could in fact produce it. *)

class ['a, _] foo = object
  method bar: 'a -> 'a = fun x -> x
end
