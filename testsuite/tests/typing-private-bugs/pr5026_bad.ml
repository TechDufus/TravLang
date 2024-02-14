(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

type untyped;;
type -'a typed = private untyped;;
type -'typing wrapped = private sexp
and +'a t = 'a typed wrapped
and sexp = private untyped wrapped;;
class type ['a] s3 = object
  val underlying : 'a t
end;;
class ['a] s3object r : ['a] s3 = object
  val underlying = r
end;;

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
