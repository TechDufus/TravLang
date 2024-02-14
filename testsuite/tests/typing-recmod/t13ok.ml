(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

(* OK *)
class type [ 'node ] extension = object method node : 'node end
class type [ 'ext ] node = object constraint 'ext = 'ext node #extension end
class x = object method node : x node = assert false end
type t = x node;;
