(* TEST *)

[@@@travlang.warning "@A"]
[@@@travlang.alert "++all"]

(* Fixture *)

module type DEPRECATED = sig end
[@@travlang.deprecated]

module T = struct
  type deprecated
  [@@travlang.deprecated]
end

(* Structure items *)

let _ = let x = 1 in ()
[@@travlang.warning "-26"]

include (struct let _ = let x = 1 in () end)
[@@travlang.warning "-26"]

module A = struct let _ = let x = 1 in () end
[@@travlang.warning "-26"]

module rec B : sig type t end = struct type t = T.deprecated end
[@@travlang.alert "-deprecated"]

module type T = sig type t = T.deprecated end
[@@travlang.alert "-deprecated"]

(* Warning 27 is unused function parameter. *)
let f _ = function[@travlang.warning "-27"]
  | x -> ()

(* Signature items *)

module type S = sig
  val x : T.deprecated
  [@@travlang.alert "-deprecated"]

  module AA : sig type t = T.deprecated end
  [@@travlang.alert "-deprecated"]

  module rec BB : sig type t = T.deprecated end
  [@@travlang.alert "-deprecated"]

  module type T = sig type t = T.deprecated end
  [@@travlang.alert "-deprecated"]

  include DEPRECATED
  [@@travlang.alert "-deprecated"]
end
