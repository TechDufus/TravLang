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

(*************************** Checkpoints *******************************)

open Int64ops
open Debugcom
open Primitives

(*** A type for checkpoints. ***)

type checkpoint_state =
    C_stopped
  | C_running of int64

(* `c_valid' is true if and only if the corresponding
 * process is connected to the debugger.
 * `c_parent' is the checkpoint whose process is parent
 * of the checkpoint one (`root' if no parent).
 * c_pid = -2 for root pseudo-checkpoint.
 * c_pid =  0 for ghost checkpoints.
 * c_pid = -1 for kill checkpoints.
 *)
type checkpoint = {
  mutable c_time : int64;
  mutable c_pid : int;
  mutable c_fd : io_channel;
  mutable c_valid : bool;
  mutable c_report : report option;
  mutable c_state : checkpoint_state;
  mutable c_parent : checkpoint;
  mutable c_breakpoint_version : int;
  mutable c_breakpoints : (pc * int ref) list;
  mutable c_trap_barrier : Sp.t;
  mutable c_code_fragments : int list
  }

(*** Pseudo-checkpoint `root'. ***)
(* --- Parents of all checkpoints which have no parent. *)
let rec root = {
  c_time = _0;
  c_pid = -2;
  c_fd = std_io;
  c_valid = false;
  c_report = None;
  c_state = C_stopped;
  c_parent = root;
  c_breakpoint_version = 0;
  c_breakpoints = [];
  c_trap_barrier = Sp.null;
  c_code_fragments = [main_frag]
  }

(*** Current state ***)
let checkpoints =
  ref ([] : checkpoint list)

let current_checkpoint =
  ref root

let current_time () =
  !current_checkpoint.c_time

let current_report () =
  !current_checkpoint.c_report

let current_pc_sp () =
  (* This pattern matching mimics the test used in debugger.c for
     deciding whether or not PC/SP should be sent with the report.
     See debugger.c, the [if] statement above the [command_loop]
     label. *)
  match current_report () with
  | Some {rep_type = Event | Breakpoint;
          rep_program_pointer = pc; rep_stack_pointer = sp } -> Some (pc, sp)
  | _ -> None

let current_pc () = Option.map fst (current_pc_sp ())
