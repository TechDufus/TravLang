(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

type expr =
  [ `Abs of string * expr
  | `App of expr * expr
  ]

class type exp =
object
  method eval : (string, exp) Hashtbl.t -> expr
end;;

class app e1 e2 : exp =
object
  val l = e1
  val r = e2
  method eval env =
      match l with
    | `Abs(var,body) ->
        Hashtbl.add env var r;
        body
    | _ -> `App(l,r);
end

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
