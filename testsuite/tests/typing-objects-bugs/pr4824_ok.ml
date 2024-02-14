(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

module M :
   sig
     class x : int -> object method m : int end
  end
=
struct
  class x _ = object
    method m = 42
  end
end;;
