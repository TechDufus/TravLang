(* TEST_BELOW
(* Blank lines added here to preserve locations. *)






*)

(* A test for inlined stack backtraces *)

let f x =
  raise (Failure "test") + 1

let g x =
  f x + 1

let h x =
  print_int (g x); print_endline "h"

let i x =
  if h x = () then ()

let () =
  let open Printexc in
  try i ()
  with _ ->
    let trace = get_raw_backtrace () in
    let print_slot slot =
      let x = convert_raw_backtrace_slot slot in
      let is_raise = Slot.is_raise x in
      let is_inline = Slot.is_inline x in
      let location = match Slot.location x with
        | None -> "<unknown>"
        | Some {filename; line_number; _} ->
            filename ^ ":" ^ Int.to_string line_number
      in
      Printf.printf "File %s%s%s\n"
        location
        (if is_inline then " (inlined)" else "")
        (if is_raise then ", raise" else "")
    in
    let rec print_slots = function
      | None -> ()
      | Some slot ->
        print_slot slot;
        print_slots (get_raw_backtrace_next_slot slot)
    in
    for i = 0 to raw_backtrace_length trace - 1 do
      let slot = get_raw_backtrace_slot trace i in
      Printf.printf "Frame %d\n" i;
      print_slots (Some slot)
    done

(* TEST
 flags = "-g";
 travlangrunparam += ",b=1";
 {
   bytecode;
 }{
   native;
 }{
   travlangopt_flags = "-O3";
   compiler_directory_suffix = ".O3";
   native;
 }
*)
