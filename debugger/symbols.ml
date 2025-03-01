(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*           Jerome Vouillon, projet Cristal, INRIA Rocquencourt          *)
(*           travlang port by John Malecki and Xavier Leroy                  *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Handling of symbol tables (globals and events) *)

open Instruct
open Debugger_config (* Toplevel *)
open Program_loading
open Debugcom
open Events
module String = Misc.Stdlib.String

let modules =
  ref ([] : string list)

let program_source_dirs =
  ref ([] : string list)

let events_by_pc =
  (Hashtbl.create 257 : (pc, debug_event) Hashtbl.t)
let events_by_module =
  (Hashtbl.create 17 : (string, int * debug_event array) Hashtbl.t)
let all_events_by_module =
  (Hashtbl.create 17 : (string, int * debug_event list) Hashtbl.t)

let partition_modules evl =
  let rec partition_modules' ev evl =
    match evl with
      [] -> [ev],[]
    | ev'::evl ->
       let evl,evll = partition_modules' ev' evl in
       if ev.ev_module = ev'.ev_module then ev::evl,evll else [ev],evl::evll
  in
  match evl with
    [] -> []
  | ev::evl -> let evl,evll = partition_modules' ev evl in evl::evll

let relocate_event orig ev =
  ev.ev_pos <- orig + ev.ev_pos;
  match ev.ev_repr with
    Event_parent repr -> repr := ev.ev_pos
  | _                 -> ()

let read_symbols' bytecode_file =
  let ic = open_in_bin bytecode_file in
  let toc =
    try
      let toc = Bytesections.read_toc ic in
      ignore(Bytesections.seek_section toc ic Bytesections.Name.SYMB);
      toc
    with Bytesections.Bad_magic_number | Not_found ->
      prerr_string bytecode_file; prerr_endline " is not a bytecode file.";
      raise Toplevel
  in
  Symtable.restore_state (input_value ic);
  begin try
    ignore (Bytesections.seek_section toc ic Bytesections.Name.DBUG)
  with Not_found ->
    prerr_string bytecode_file; prerr_endline " has no debugging info.";
    raise Toplevel
  end;
  let num_eventlists = input_binary_int ic in
  let dirs = ref String.Set.empty in
  let eventlists = ref [] in
  for _i = 1 to num_eventlists do
    let orig = input_binary_int ic in
    let evl = (input_value ic : debug_event list) in
    (* Relocate events in event list *)
    List.iter (relocate_event orig) evl;
    let evll = partition_modules evl in
    eventlists := evll @ !eventlists;
    dirs :=
      List.fold_left (fun s e -> String.Set.add e s) !dirs (input_value ic)
  done;
  begin try
    ignore (Bytesections.seek_section toc ic Bytesections.Name.CODE)
  with Not_found ->
    (* The file contains only debugging info,
       loading mode is forced to "manual" *)
    set_launching_function (List.assoc "manual" loading_modes)
  end;
  close_in_noerr ic;
  !eventlists, !dirs

let clear_symbols () =
  modules := [];
  program_source_dirs := [];
  Hashtbl.clear events_by_pc; Hashtbl.clear events_by_module;
  Hashtbl.clear all_events_by_module

let add_symbols frag all_events =
  List.iter
    (fun evl ->
      List.iter
        (fun ev ->
          Hashtbl.add events_by_pc {frag; pos = ev.ev_pos} ev)
        evl)
    all_events;

  List.iter
    (function
        [] -> ()
      | ev :: _ as evl ->
          let md = ev.ev_module in
          let cmp ev1 ev2 = compare (Events.get_pos ev1).Lexing.pos_cnum
                                    (Events.get_pos ev2).Lexing.pos_cnum
          in
          let sorted_evl = List.sort cmp evl in
          modules := md :: !modules;
          Hashtbl.add all_events_by_module md (frag, sorted_evl);
          let real_evl =
            List.filter
              (function
                 {ev_kind = Event_pseudo} -> false
               | _                        -> true)
              sorted_evl
          in
          Hashtbl.add events_by_module md (frag, Array.of_list real_evl))
    all_events

let read_symbols frag bytecode_file =
  let all_events, all_dirs = read_symbols' bytecode_file in
  program_source_dirs := !program_source_dirs @ (String.Set.elements all_dirs);
  add_symbols frag all_events

let erase_symbols frag =
  let pcs = Hashtbl.fold (fun pc _ pcs ->
      if pc.frag = frag then pc :: pcs else pcs)
    events_by_pc []
  in
  List.iter (Hashtbl.remove events_by_pc) pcs;

  let mds = Hashtbl.fold (fun md (frag', _) mds ->
      if frag' = frag then md :: mds else mds)
    events_by_module []
  in
  List.iter (Hashtbl.remove events_by_module) mds;
  List.iter (Hashtbl.remove all_events_by_module) mds;
  modules := List.filter (fun md -> not (List.mem md mds)) !modules

let code_fragments () =
  let frags =
    Hashtbl.fold
      (fun _ (frag, _) l -> frag :: l)
      all_events_by_module []
  in
  List.sort_uniq compare frags

let modules_in_code_fragment frag' =
  Hashtbl.fold (fun md (frag, _) l ->
      if frag' = frag then md :: l else l)
    all_events_by_module []

let any_event_at_pc pc =
  { ev_frag = pc.frag; ev_ev = Hashtbl.find events_by_pc pc }

let event_at_pc pc =
  match any_event_at_pc pc with
    { ev_ev = { ev_kind = Event_pseudo } } -> raise Not_found
  | ev -> ev

let set_event_at_pc pc =
 try ignore(event_at_pc pc); set_event pc
 with Not_found -> ()

(* List all events in module *)
let events_in_module mdle =
  try
    Hashtbl.find all_events_by_module mdle
  with Not_found ->
    0, []

(* Binary search of event at or just after char *)
let find_event ev char =
  let rec bsearch lo hi =
    if lo >= hi then begin
      if (Events.get_pos ev.(hi)).Lexing.pos_cnum < char
      then raise Not_found
      else hi
    end else begin
      let pivot = (lo + hi) / 2 in
      let e = ev.(pivot) in
      if char <= (Events.get_pos e).Lexing.pos_cnum
      then bsearch lo pivot
      else bsearch (pivot + 1) hi
    end
  in
  if Array.length ev = 0 then
    raise Not_found
  else
    bsearch 0 (Array.length ev - 1)

(* Return first event after the given position. *)
(* Raise [Not_found] if module is unknown or no event is found. *)
let event_at_pos md char =
  let ev_frag, ev = Hashtbl.find events_by_module md in
  { ev_frag; ev_ev = ev.(find_event ev char) }

(* Return event closest to given position *)
(* Raise [Not_found] if module is unknown or no event is found. *)
let event_near_pos md char =
  let ev_frag, ev = Hashtbl.find events_by_module md in
  try
    let pos = find_event ev char in
    (* Desired event is either ev.(pos) or ev.(pos - 1),
       whichever is closest *)
    if pos > 0 && char - (Events.get_pos ev.(pos - 1)).Lexing.pos_cnum
                  <= (Events.get_pos ev.(pos)).Lexing.pos_cnum - char
    then { ev_frag; ev_ev = ev.(pos - 1) }
    else { ev_frag; ev_ev = ev.(pos) }
  with Not_found ->
    let pos = Array.length ev - 1 in
    if pos < 0 then raise Not_found;
    { ev_frag; ev_ev = ev.(pos) }

(* Flip "event" bit on all instructions *)
let set_all_events frag =
  Hashtbl.iter
    (fun pc ev ->
       match ev.ev_kind with
         Event_pseudo -> ()
       | _ when pc.frag = frag -> set_event pc
       | _ -> ())
    events_by_pc

(* Previous `pc'. *)
(* Save time if `update_current_event' is called *)
(* several times at the same point. *)
let old_pc = ref (None : pc option)

(* Recompute the current event *)
let update_current_event () =
  match Checkpoints.current_pc () with
    None ->
      Events.current_event := None;
      old_pc := None
  | (Some pc) as opt_pc when opt_pc <> !old_pc ->
      Events.current_event :=
        begin try
          Some (event_at_pc pc)
        with Not_found ->
          None
        end;
      old_pc := opt_pc
  | _ ->
      ()
