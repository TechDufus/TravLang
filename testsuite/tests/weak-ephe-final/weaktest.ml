(* TEST *)

let debug = false;;

open Printf;;

module Hashed = struct
  type t = string list;;
  let equal x y =
    eprintf "equal: %s / %s\n" (List.hd x) (List.hd y);
    x = y
  ;;
  let hash x = Hashtbl.hash (List.hd x);;
end;;

module HT = Weak.Make (Hashed);;

let tbl = HT.create 7;;

let r = ref [];;

let bunch =
  if Array.length Sys.argv < 2
  then 10000
  else int_of_string Sys.argv.(1)
;;

Random.init 314;;

let random_string n =
  String.init n (fun _ -> Char.chr (32 + Random.int 95))
;;

let added = ref 0;;
let mistakes = ref 0;;

let print_status () =
  let (len, entries, sumbuck, buckmin, buckmed, buckmax) = HT.stats tbl in
  if entries > bunch * (!added + 1) then begin
    if debug then begin
      printf "\n===================\n";
      printf "len = %d\n" len;
      printf "entries = %d\n" entries;
      printf "sum of bucket sizes = %d\n" sumbuck;
      printf "min bucket = %d\n" buckmin;
      printf "med bucket = %d\n" buckmed;
      printf "max bucket = %d\n" buckmax;
      printf "GC count = %d\n" (Gc.quick_stat ()).Gc.major_collections;
      flush stdout;
    end;
    incr mistakes;
  end;
  added := 0;
;;

Gc.create_alarm print_status;;

for j = 0 to 99 do
  r := [];
  incr added;

  (* Ephemeron / Weak array implementation in multicore travlang differs
     significantly from stock travlang. In particular, ephemerons keys and data in
     the minor heap are considered roots for the minor collection. Moreover,
     When blit'ing ephemerons, the source keys and data are marked as live to
     play nicely with the concurrent major GC. As a result, this test keeps the
     previous bunches of strings alive longer than on stock. Hence, the test as
     is fails on multicore. We add a [full_major] call that forces old bunches
     to be collected and to confirm that ephemeron implementation on multicore
     does work as intended. *)
  Gc.full_major ();

  for i = 1 to bunch do
    let c = random_string 7 in
    r := c :: !r;
    HT.add tbl !r;
  done;
done;;

if !mistakes < 5 then printf "pass\n" else printf "fail\n";;
