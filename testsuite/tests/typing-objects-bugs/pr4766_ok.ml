(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

class virtual ['a] c =
object (s : 'a)
  method virtual m : 'b
end

let o =
    object (s :'a)
      inherit ['a] c
      method m = 42
    end
