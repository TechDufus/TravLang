(* TEST_BELOW
Filler_text_added_
to_preserve_locations_while_tran
slating_from_old_syntax__Filler_
text_added_to_pre
serve_locations_while_translati
*)

[%%foo let x = 1 in x]
let [%foo 2+1] : [%foo bar.baz] = [%foo "foo"]

[%%foo module M = [%bar] ]
let [%foo let () = () ] : [%foo type t = t ] = [%foo class c = object end]

[%%foo: 'a list]
let [%foo: [`Foo] ] : [%foo: t -> t ] = [%foo: < foo : t > ]

[%%foo? _ ]
[%%foo? Some y when y > 0]
let [%foo? (Bar x | Baz x) ] : [%foo? #bar ] = [%foo? { x }]

[%%foo: module M : [%baz]]
let [%foo: include S with type t = t ]
  : [%foo: val x : t  val y : t]
  = [%foo: type t = t ]

(* TEST
 flags = "-dparsetree";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
