(* TEST
 expect;
*)

[@@@travlang.warning "+3"];;

module X: sig
  type t [@@travlang.deprecated]
  type s [@@travlang.deprecated]
  type u [@@travlang.deprecated]
  val x: t [@@travlang.deprecated]
end = struct
  type t = int
  type s
  type u
  let x = 0
end;;
[%%expect{|
Line 7, characters 9-10:
7 |   val x: t [@@travlang.deprecated]
             ^
Alert deprecated: t

module X : sig type t type s type u val x : t end
|}]

type t = X.t
;;
[%%expect{|
Line 1, characters 9-12:
1 | type t = X.t
             ^^^
Alert deprecated: X.t

type t = X.t
|}]

let x = X.x
;;
[%%expect{|
Line 1, characters 8-11:
1 | let x = X.x
            ^^^
Alert deprecated: X.x

val x : X.t = <abstr>
|}]

(* Patterns *)

let (_, foo [@deprecated], _) = 1, (), 3
;;
foo;;
[%%expect{|
val foo : unit = ()
Line 3, characters 0-3:
3 | foo;;
    ^^^
Alert deprecated: foo

- : unit = ()
|}]

let (_, foo, bar) [@deprecated] = 1, (), 3
;;
foo;;
[%%expect{|
val foo : unit = ()
val bar : int = 3
- : unit = ()
|}]

let f = function
  | bar, cho [@deprecated], _ -> cho + 1
;;
[%%expect{|
Line 2, characters 33-36:
2 |   | bar, cho [@deprecated], _ -> cho + 1
                                     ^^^
Alert deprecated: cho

val f : 'a * int * 'b -> int = <fun>
|}]

class c (_, (foo [@deprecated] : int)) =
  object
    val h = foo
  end
;;
[%%expect{|
Line 3, characters 12-15:
3 |     val h = foo
                ^^^
Alert deprecated: foo

class c : 'a * int -> object val h : int end
|}]

(* Type declarations *)

type t = X.t * X.s
;;
[%%expect{|
Line 1, characters 9-12:
1 | type t = X.t * X.s
             ^^^
Alert deprecated: X.t

Line 1, characters 15-18:
1 | type t = X.t * X.s
                   ^^^
Alert deprecated: X.s

type t = X.t * X.s
|}]

type t = X.t * X.s [@@travlang.warning "-3"]
;;
[%%expect{|
type t = X.t * X.s
|}]

type t1 = X.t [@@travlang.warning "-3"]
and t2 = X.s
;;
[%%expect{|
Line 2, characters 9-12:
2 | and t2 = X.s
             ^^^
Alert deprecated: X.s

type t1 = X.t
and t2 = X.s
|}]

type t = A of t [@@travlang.deprecated]
;;
[%%expect{|
Line 1, characters 14-15:
1 | type t = A of t [@@travlang.deprecated]
                  ^
Alert deprecated: t

type t = A of t
|}]

type t = A of t
  [@@travlang.deprecated]
  [@@travlang.warning "-3"]
;;
[%%expect{|
type t = A of t
|}]

(* Type expressions *)

type t = (X.t * X.s) [@travlang.warning "-3"]
;;
[%%expect{|
type t = X.t * X.s
|}]

type t = (X.t [@travlang.warning "-3"]) * X.s
;;
[%%expect{|
Line 1, characters 39-42:
1 | type t = (X.t [@travlang.warning "-3"]) * X.s
                                           ^^^
Alert deprecated: X.s

type t = X.t * X.s
|}]


type t = A of (t [@travlang.warning "-3"])
  [@@travlang.deprecated]
;;
[%%expect{|
type t = A of t
|}]

(* Pattern expressions *)

let _ = function (_ : X.t) -> ()
;;
[%%expect{|
Line 1, characters 22-25:
1 | let _ = function (_ : X.t) -> ()
                          ^^^
Alert deprecated: X.t

- : X.t -> unit = <fun>
|}]

let _ = function (_ : X.t)[@travlang.warning "-3"] -> ()
;;
[%%expect{|
- : X.t -> unit = <fun>
|}]


(* Module expressions and module declarations *)

module M = struct let x = X.x end
;;
[%%expect{|
Line 1, characters 26-29:
1 | module M = struct let x = X.x end
                              ^^^
Alert deprecated: X.x

module M : sig val x : X.t end
|}]

module M = (struct let x = X.x end)[@travlang.warning "-3"]
;;
[%%expect{|
module M : sig val x : X.t end
|}]

module M = struct let x = X.x end [@@travlang.warning "-3"]
;;
[%%expect{|
module M : sig val x : X.t end
|}]


module rec M : sig val x: X.t end = struct let x = X.x end
[%%expect{|
Line 1, characters 26-29:
1 | module rec M : sig val x: X.t end = struct let x = X.x end
                              ^^^
Alert deprecated: X.t

Line 1, characters 51-54:
1 | module rec M : sig val x: X.t end = struct let x = X.x end
                                                       ^^^
Alert deprecated: X.x

module rec M : sig val x : X.t end
|}]

module rec M : sig val x: X.t end =
  struct
    let x = X.x
  end [@@travlang.warning "-3"]
[%%expect{|
module rec M : sig val x : X.t end
|}]

module rec M :
  (sig val x: X.t end)[@travlang.warning "-3"] =
  (struct let x = X.x end)[@travlang.warning "-3"]
[%%expect{|
module rec M : sig val x : X.t end
|}]

module rec M :
  (sig val x: X.t end)[@travlang.warning "-3"] =
  struct let x = X.x end
[%%expect{|
Line 3, characters 17-20:
3 |   struct let x = X.x end
                     ^^^
Alert deprecated: X.x

module rec M : sig val x : X.t end
|}]

(* Module type expressions and module type declarations *)

module type S = sig type t = X.t end
;;
[%%expect{|
Line 1, characters 29-32:
1 | module type S = sig type t = X.t end
                                 ^^^
Alert deprecated: X.t

module type S = sig type t = X.t end
|}]

module type S = (sig type t = X.t end)[@travlang.warning "-3"]
;;
[%%expect{|
module type S = sig type t = X.t end
|}]

module type S = sig type t = X.t end[@@travlang.warning "-3"]
;;
[%%expect{|
module type S = sig type t = X.t end
|}]


(* Class expressions, class declarations and class fields *)

class c = object method x = X.x end
;;
[%%expect{|
Line 1, characters 28-31:
1 | class c = object method x = X.x end
                                ^^^
Alert deprecated: X.x

class c : object method x : X.t end
|}]

class c = object method x = X.x end[@@travlang.warning "-3"]
;;
[%%expect{|
class c : object method x : X.t end
|}]

class c = (object method x = X.x end)[@travlang.warning "-3"]
;;
[%%expect{|
class c : object method x : X.t end
|}]

class c = object method x = X.x [@@travlang.warning "-3"] end
;;
[%%expect{|
class c : object method x : X.t end
|}]

(* Class type expressions, class type declarations
   and class type fields *)

class type c = object method x : X.t end
;;
[%%expect{|
Line 1, characters 33-36:
1 | class type c = object method x : X.t end
                                     ^^^
Alert deprecated: X.t

class type c = object method x : X.t end
|}]

class type c = object method x : X.t end[@@travlang.warning "-3"]
;;
[%%expect{|
class type c = object method x : X.t end
|}]

class type c = object method x : X.t end[@travlang.warning "-3"]
;;
[%%expect{|
class type c = object method x : X.t end
|}]

class type c = object method x : X.t [@@travlang.warning "-3"] end
;;
[%%expect{|
class type c = object method x : X.t end
|}]



(* External declarations *)

external foo: unit -> X.t = "foo"
;;
[%%expect{|
Line 1, characters 22-25:
1 | external foo: unit -> X.t = "foo"
                          ^^^
Alert deprecated: X.t

external foo : unit -> X.t = "foo"
|}]

external foo: unit -> X.t = "foo"[@@travlang.warning "-3"]
;;
[%%expect{|
external foo : unit -> X.t = "foo"
|}]


(* Eval *)
;;
X.x
;;
[%%expect{|
Line 1, characters 0-3:
1 | X.x
    ^^^
Alert deprecated: X.x

- : X.t = <abstr>
|}]

;;
X.x [@@travlang.warning "-3"]
;;
[%%expect{|
- : X.t = <abstr>
|}]

(* Open / include *)

module D = struct end[@@travlang.deprecated]

open D
;;
[%%expect{|
module D : sig end
Line 3, characters 5-6:
3 | open D
         ^
Alert deprecated: module D
|}]

open D [@@travlang.warning "-3"]
;;
[%%expect{|
|}]

include D
;;
[%%expect{|
Line 1, characters 8-9:
1 | include D
            ^
Alert deprecated: module D
|}]

include D [@@travlang.warning "-3"]
;;
[%%expect{|
|}]


(* Type extensions *)

type ext = ..
;;
[%%expect{|
type ext = ..
|}]

type ext +=
  | A of X.t
  | B of (X.s [@travlang.warning "-3"])
  | C of X.u [@travlang.warning "-3"]
;;
[%%expect{|
Line 2, characters 9-12:
2 |   | A of X.t
             ^^^
Alert deprecated: X.t

type ext += A of X.t | B of X.s | C of X.u
|}]

type ext +=
  | C of X.t
  [@@travlang.warning "-3"]
;;
[%%expect{|
type ext += C of X.t
|}]


exception Foo of X.t
;;
[%%expect{|
Line 1, characters 17-20:
1 | exception Foo of X.t
                     ^^^
Alert deprecated: X.t

exception Foo of X.t
|}]

exception Foo of X.t [@travlang.warning "-3"]
;;
[%%expect{|
exception Foo of X.t
|}]


(* Labels/constructors/fields *)

type t =
  | A of X.t
  | B of X.s [@travlang.warning "-3"]
  | C of (X.u [@travlang.warning "-3"])
;;
[%%expect{|
Line 2, characters 9-12:
2 |   | A of X.t
             ^^^
Alert deprecated: X.t

type t = A of X.t | B of X.s | C of X.u
|}]

type t =
  {
    a: X.t;
    b: X.s [@travlang.warning "-3"];
    c: (X.u [@travlang.warning "-3"]);
  }
;;
[%%expect{|
Line 3, characters 7-10:
3 |     a: X.t;
           ^^^
Alert deprecated: X.t

type t = { a : X.t; b : X.s; c : X.u; }
|}]


type t =
  <
    a: X.t;
    b: X.s [@travlang.warning "-3"];
    c: (X.u [@travlang.warning "-3"]);
  >
;;
[%%expect{|
Line 3, characters 7-10:
3 |     a: X.t;
           ^^^
Alert deprecated: X.t

type t = < a : X.t; b : X.s; c : X.u >
|}]


type t =
  [
  | `A of X.t
  | `B of X.s [@travlang.warning "-3"]
  | `C of (X.u [@travlang.warning "-3"])
  ]
;;
[%%expect{|
Line 3, characters 10-13:
3 |   | `A of X.t
              ^^^
Alert deprecated: X.t

type t = [ `A of X.t | `B of X.s | `C of X.u ]
|}]


(* Test for travlang.ppwarning, and its interactions with travlang.warning *)


[@@@travlang.ppwarning "Pp warning!"]
;;
[%%expect{|
Line 1, characters 20-33:
1 | [@@@travlang.ppwarning "Pp warning!"]
                        ^^^^^^^^^^^^^
Warning 22 [preprocessor]: Pp warning!
|}]


let x = () [@travlang.ppwarning "Pp warning 1!"]
    [@@travlang.ppwarning  "Pp warning 2!"]
;;
[%%expect{|
Line 2, characters 24-39:
2 |     [@@travlang.ppwarning  "Pp warning 2!"]
                            ^^^^^^^^^^^^^^^
Warning 22 [preprocessor]: Pp warning 2!

Line 1, characters 29-44:
1 | let x = () [@travlang.ppwarning "Pp warning 1!"]
                                 ^^^^^^^^^^^^^^^
Warning 22 [preprocessor]: Pp warning 1!

val x : unit = ()
|}]

type t = unit
    [@travlang.ppwarning "Pp warning!"]
;;
[%%expect{|
Line 2, characters 22-35:
2 |     [@travlang.ppwarning "Pp warning!"]
                          ^^^^^^^^^^^^^
Warning 22 [preprocessor]: Pp warning!

type t = unit
|}]

module X = struct
  [@@@travlang.warning "-22"]

  [@@@travlang.ppwarning "Pp warning1!"]

  [@@@travlang.warning "+22"]

  [@@@travlang.ppwarning "Pp warning2!"]
end
;;
[%%expect{|
Line 8, characters 22-36:
8 |   [@@@travlang.ppwarning "Pp warning2!"]
                          ^^^^^^^^^^^^^^
Warning 22 [preprocessor]: Pp warning2!

module X : sig end
|}]

let x =
  ((() [@travlang.ppwarning "Pp warning 1!"]) [@travlang.warning "-22"])
    [@travlang.ppwarning  "Pp warning 2!"]
;;
[%%expect{|
Line 3, characters 23-38:
3 |     [@travlang.ppwarning  "Pp warning 2!"]
                           ^^^^^^^^^^^^^^^
Warning 22 [preprocessor]: Pp warning 2!

val x : unit = ()
|}]

type t =
  ((unit [@travlang.ppwarning "Pp warning 1!"]) [@travlang.warning "-22"])
  [@travlang.ppwarning  "Pp warning 2!"]
  [@@travlang.ppwarning "Pp warning 3!"]
;;
[%%expect{|
Line 4, characters 21-36:
4 |   [@@travlang.ppwarning "Pp warning 3!"]
                         ^^^^^^^^^^^^^^^
Warning 22 [preprocessor]: Pp warning 3!

Line 3, characters 21-36:
3 |   [@travlang.ppwarning  "Pp warning 2!"]
                         ^^^^^^^^^^^^^^^
Warning 22 [preprocessor]: Pp warning 2!

type t = unit
|}]

let ([][@travlang.ppwarning "XX"]) = []
;;
[%%expect{|
Line 1, characters 25-29:
1 | let ([][@travlang.ppwarning "XX"]) = []
                             ^^^^
Warning 22 [preprocessor]: XX

Line 1, characters 4-31:
1 | let ([][@travlang.ppwarning "XX"]) = []
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
_::_
|}]
let[@travlang.warning "-8-22"] ([][@travlang.ppwarning "XX"]) = []
;;
[%%expect{|
|}]
