(* TEST
 flags = "-g";
 native;
*)

(* Check the effectiveness of inlining the wrapper which fills in
   default values for optional arguments.

   Ref: http://caml.inria.fr/mantis/view.php?id=6345
*)


let rec f ?(flag = false) ?(acc = 0) = function
  | [] -> if flag then acc else acc + 1
  | hd :: tl -> f ~flag ~acc:(acc + hd) tl

let () =
  let l = [1;2;3;4;5;6;7;8;9] in
  let x0 = Gc.allocated_bytes () in
  let x1 = Gc.allocated_bytes () in
  for i = 1 to 1000 do
    ignore (f l)
  done;
  let x2 = Gc.allocated_bytes () in
  assert(x1 -. x0 = x2 -. x1)
     (* check that we have not allocated anything between x1 and x2 *)


(* Check that 'travlang.inline always' is not broken due to the split
   into a worker+wrapper. *)


let[@travlang.inline always] f ?(x = 1.) a b = a +. b *. x
let () =
  let r = ref 0. in
  let x0 = Gc.allocated_bytes () in
  let x1 = Gc.allocated_bytes () in
  for _ = 1 to 1000 do
    r := !r +. f 1. 1.
  done;
  let x2 = Gc.allocated_bytes () in
  assert(x1 -. x0 = x2 -. x1)
  (* If the body of `f` itself were not inlined, we would get float
     boxing allocations. *)
