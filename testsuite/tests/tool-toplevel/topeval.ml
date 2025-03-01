(* TEST
 {
   toplevel;
 }{
   toplevel.opt;
 }
*)

(* Various test-cases ensuring that the native and bytecode toplevels produce
   the same output *)

(* PR 10712 *)
module A : sig
  type ('foo, 'bar) t

  val get_foo : ('foo, _) t -> 'foo option
end = struct
  type ('foo, 'bar) t =
    | Foo of 'foo
    | Bar of 'bar

  let get_foo = function
    | Foo foo -> Some foo
    | Bar _ -> None
end
;;

(* Type variables should be 'foo and 'a (name persists) *)
A.get_foo
;;

(* Type variables be 'a and 'b (original names lost in let-binding) *)
let _bar = A.get_foo
;;

(* PR 10849 *)
let _ : int = 42
;;

let (_ : bool) : bool = false
;;

let List.(_) = ""
;;

let List.(String.(_)) = 'd'
;;

let List.(_) : float = 42.0
;;

(* issue #12257: external or module alias followed by regular value triggers
   an exception in travlangnat *)
external foo : int -> int -> int = "%addint"
module S = String
let x = 42
;;

(* Check that frametables are correctly loaded by triggering GC *)
let () =
  Gc.minor ();
  let r = List.init 1000 Sys.opaque_identity in
  Gc.minor ();
  let _ = Sys.opaque_identity (List.init 1000 (fun _ -> "!")) in
  List.iteri (fun i j -> assert (i = j)) r;
  ()
;;
