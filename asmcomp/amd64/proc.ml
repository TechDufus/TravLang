# 2 "asmcomp/amd64/proc.ml"
(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 2000 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Description of the AMD64 processor *)

open Misc
open Arch
open Cmm
open Reg
open Mach

let fp = Config.with_frame_pointers

(* Which ABI to use *)

let win64 = Arch.win64

(* Registers available for register allocation *)

(* Register map:
    rax         0
    rbx         1
    rdi         2
    rsi         3
    rdx         4
    rcx         5
    r8          6
    r9          7
    r12         8
    r13         9
    r10         10
    r11         11
    rbp         12
    r14         domain state pointer
    r15         allocation pointer

  xmm0 - xmm15  100 - 115  *)

(* Conventions:
     rax - r13: travlang function arguments
     rax: travlang and C function results
     xmm0 - xmm9: travlang function arguments
     xmm0: travlang and C function results
   Under Unix:
     rdi, rsi, rdx, rcx, r8, r9: C function arguments
     xmm0 - xmm7: C function arguments
     rbx, rbp, r12-r15 are preserved by C
     xmm registers are not preserved by C
   Under Win64:
     rcx, rdx, r8, r9: C function arguments
     xmm0 - xmm3: C function arguments
     rbx, rbp, rsi, rdi r12-r15 are preserved by C
     xmm6-xmm15 are preserved by C
   Note (PR#5707, GPR#1304): PLT stubs (used for dynamic resolution of symbols
     on Unix-like platforms) may clobber any register except those used for:
       1. C parameter passing;
       2. C return values;
       3. C callee-saved registers.
     This translates to the set { r10, r11 }.  These registers hence cannot
     be used for travlang parameter passing and must also be marked as
     destroyed across [Ialloc] and [Ipoll] (otherwise a call to
     caml_call_gc@PLT might clobber these two registers before the assembly
     stub saves them into the GC regs block).
*)

let int_reg_name =
  match Config.ccomp_type with
  | "msvc" ->
      [| "rax"; "rbx"; "rdi"; "rsi"; "rdx"; "rcx"; "r8"; "r9";
         "r12"; "r13"; "r10"; "r11"; "rbp" |]
  | _ ->
      [| "%rax"; "%rbx"; "%rdi"; "%rsi"; "%rdx"; "%rcx"; "%r8"; "%r9";
         "%r12"; "%r13"; "%r10"; "%r11"; "%rbp" |]

let float_reg_name =
  match Config.ccomp_type with
  | "msvc" ->
      [| "xmm0"; "xmm1"; "xmm2"; "xmm3"; "xmm4"; "xmm5"; "xmm6"; "xmm7";
         "xmm8"; "xmm9"; "xmm10"; "xmm11";
         "xmm12"; "xmm13"; "xmm14"; "xmm15" |]
  | _ ->
      [| "%xmm0"; "%xmm1"; "%xmm2"; "%xmm3"; "%xmm4"; "%xmm5"; "%xmm6"; "%xmm7";
         "%xmm8"; "%xmm9"; "%xmm10"; "%xmm11";
         "%xmm12"; "%xmm13"; "%xmm14"; "%xmm15" |]

let num_register_classes = 2

let register_class r =
  match r.typ with
  | Val | Int | Addr -> 0
  | Float -> 1

let num_available_registers = [| 13; 16 |]

let first_available_register = [| 0; 100 |]

let register_name r =
  if r < 100 then int_reg_name.(r) else float_reg_name.(r - 100)

(* Pack registers starting at %rax so as to reduce the number of REX
   prefixes and thus improve code density *)
let rotate_registers = false

(* Representation of hard registers by pseudo-registers *)

let hard_int_reg =
  let v = Array.make 13 Reg.dummy in
  for i = 0 to 12 do v.(i) <- Reg.at_location Int (Reg i) done;
  v

let hard_float_reg =
  let v = Array.make 16 Reg.dummy in
  for i = 0 to 15 do v.(i) <- Reg.at_location Float (Reg (100 + i)) done;
  v

let all_phys_regs =
  Array.append hard_int_reg hard_float_reg

let phys_reg n =
  if n < 100 then hard_int_reg.(n) else hard_float_reg.(n - 100)

let rax = phys_reg 0
let rdx = phys_reg 4
let r10 = phys_reg 10
let r11 = phys_reg 11
let rbp = phys_reg 12
let rxmm15 = phys_reg 115

let destroyed_by_plt_stub =
  if not X86_proc.use_plt then [| |] else [| r10; r11 |]

let num_destroyed_by_plt_stub = Array.length destroyed_by_plt_stub

let destroyed_by_plt_stub_set = Reg.set_of_array destroyed_by_plt_stub

let stack_slot slot ty =
  Reg.at_location ty (Stack slot)

(* Instruction selection *)

let word_addressed = false

(* Calling conventions *)

let size_domainstate_args = 64 * size_int

let calling_conventions first_int last_int first_float last_float
                        make_stack first_stack
                        arg =
  let loc = Array.make (Array.length arg) Reg.dummy in
  let int = ref first_int in
  let float = ref first_float in
  let ofs = ref first_stack in
  for i = 0 to Array.length arg - 1 do
    match arg.(i) with
    | Val | Int | Addr as ty ->
        if !int <= last_int then begin
          loc.(i) <- phys_reg !int;
          incr int
        end else begin
          loc.(i) <- stack_slot (make_stack !ofs) ty;
          ofs := !ofs + size_int
        end;
        assert (not (Reg.Set.mem loc.(i) destroyed_by_plt_stub_set))
    | Float ->
        if !float <= last_float then begin
          loc.(i) <- phys_reg !float;
          incr float
        end else begin
          loc.(i) <- stack_slot (make_stack !ofs) Float;
          ofs := !ofs + size_float
        end
  done;
  (loc, Misc.align (max 0 !ofs) 16)  (* keep stack 16-aligned *)

let incoming ofs =
  if ofs >= 0
  then Incoming ofs
  else Domainstate (ofs + size_domainstate_args)
let outgoing ofs =
  if ofs >= 0
  then Outgoing ofs
  else Domainstate (ofs + size_domainstate_args)
let not_supported _ofs = fatal_error "Proc.loc_results: cannot call"

let loc_arguments arg =
  calling_conventions 0 9 100 109 outgoing (- size_domainstate_args) arg
let loc_parameters arg =
  let (loc, _ofs) =
    calling_conventions 0 9 100 109 incoming (- size_domainstate_args) arg
  in loc
let loc_results res =
  let (loc, _ofs) = calling_conventions 0 0 100 100 not_supported 0 res
  in loc

let max_arguments_for_tailcalls = 10 (* in regs *) + 64 (* in domain state *)

(* C calling conventions under Unix:
     first integer args in rdi, rsi, rdx, rcx, r8, r9
     first float args in xmm0 ... xmm7
     remaining args on stack
     return value in rax or xmm0.
  C calling conventions under Win64:
     first integer args in rcx, rdx, r8, r9
     first float args in xmm0 ... xmm3
     each integer arg consumes a float reg, and conversely
     remaining args on stack
     always 32 bytes reserved at bottom of stack.
     Return value in rax or xmm0. *)

let loc_external_results res =
  let (loc, _ofs) = calling_conventions 0 0 100 100 not_supported 0 res in loc

let unix_loc_external_arguments arg =
  calling_conventions 2 7 100 107 outgoing 0 arg

let win64_int_external_arguments =
  [| 5 (*rcx*); 4 (*rdx*); 6 (*r8*); 7 (*r9*) |]
let win64_float_external_arguments =
  [| 100 (*xmm0*); 101 (*xmm1*); 102 (*xmm2*); 103 (*xmm3*) |]

let win64_loc_external_arguments arg =
  let loc = Array.make (Array.length arg) Reg.dummy in
  let reg = ref 0
  and ofs = ref 0 in
  for i = 0 to Array.length arg - 1 do
    match arg.(i) with
    | Val | Int | Addr as ty ->
        if !reg < 4 then begin
          loc.(i) <- phys_reg win64_int_external_arguments.(!reg);
          incr reg
        end else begin
          loc.(i) <- stack_slot (Outgoing !ofs) ty;
          ofs := !ofs + size_int
        end
    | Float ->
        if !reg < 4 then begin
          loc.(i) <- phys_reg win64_float_external_arguments.(!reg);
          incr reg
        end else begin
          loc.(i) <- stack_slot (Outgoing !ofs) Float;
          ofs := !ofs + size_float
        end
  done;
  (loc, Misc.align !ofs 16)  (* keep stack 16-aligned *)

let loc_external_arguments ty_args =
  let arg = Cmm.machtype_of_exttype_list ty_args in
  let loc, stack_ofs =
    if win64
    then win64_loc_external_arguments arg
    else unix_loc_external_arguments arg
  in
  Array.map (fun reg -> [|reg|]) loc, stack_ofs

let loc_exn_bucket = rax

(** See "System V Application Binary Interface, AMD64 Architecture Processor
    Supplement" (www.x86-64.org/documentation/abi.pdf) page 57, fig. 3.36. *)
let int_dwarf_reg_numbers =
  [| 0; 3; 5; 4; 1; 2; 8; 9; 12; 13; 10; 11; 6 |]

let float_dwarf_reg_numbers =
  [| 17; 18; 19; 20; 21; 22; 23; 24; 25; 26; 27; 28; 29; 30; 31; 32 |]

let dwarf_register_numbers ~reg_class =
  match reg_class with
  | 0 -> int_dwarf_reg_numbers
  | 1 -> float_dwarf_reg_numbers
  | _ -> Misc.fatal_errorf "Bad register class %d" reg_class

let stack_ptr_dwarf_register_number = 7

(* Registers destroyed by operations *)

let destroyed_at_c_call =
  (* C calling conventions preserve rbx, but it is clobbered
     by the code sequence used for C calls in emit.mlp, so it
     is marked as destroyed. *)
  if win64 then
    (* Win64: rsi, rdi, r12-r15, xmm6-xmm15 preserved *)
    Array.of_list(List.map phys_reg
      [0;1;4;5;6;7;10;11;12;
       100;101;102;103;104;105])
  else
    (* Unix: r12-r15 preserved *)
    Array.of_list(List.map phys_reg
      [0;1;2;3;4;5;6;7;10;11;
       100;101;102;103;104;105;106;107;
       108;109;110;111;112;113;114;115])

let destroyed_at_alloc_or_poll =
  if X86_proc.use_plt then
    destroyed_by_plt_stub
  else
    [| r11 |]

let destroyed_at_oper = function
    Iop(Icall_ind | Icall_imm _) ->
      all_phys_regs
  | Iop(Iextcall {alloc; stack_ofs; }) ->
      assert (stack_ofs >= 0);
      if alloc || stack_ofs > 0 then all_phys_regs
      else destroyed_at_c_call
  | Iop(Iintop(Idiv | Imod)) | Iop(Iintop_imm((Idiv | Imod), _))
        -> [| rax; rdx |]
  | Iop(Istore(Single, _, _)) -> [| rxmm15 |]
  | Iop(Ialloc _ | Ipoll _) -> destroyed_at_alloc_or_poll
  | Iop(Iintop(Imulh | Icomp _) | Iintop_imm((Icomp _), _))
        -> [| rax |]
  | Iswitch(_, _) -> [| rax; rdx |]
  | Itrywith _ -> [| r11 |]
  | _ ->
    if fp then
(* prevent any use of the frame pointer ! *)
      [| rbp |]
    else
      [||]


let destroyed_at_raise = all_phys_regs

let destroyed_at_reloadretaddr = [| |]

(* Maximal register pressure *)


let safe_register_pressure = function
    Iextcall _ -> if win64 then if fp then 7 else 8 else 0
  | _ -> if fp then 10 else 11

let max_register_pressure =
  let consumes ~int ~float =
    if fp
    then [| 12 - int; 16 - float |]
    else [| 13 - int; 16 - float |]
  in
  function
    Iextcall _ ->
      if win64
      then consumes ~int:5 ~float:6
      else consumes ~int:9 ~float:16
  | Iintop(Idiv | Imod) | Iintop_imm((Idiv | Imod), _) ->
      consumes ~int:2 ~float:0
  | Ialloc _ | Ipoll _ ->
      consumes ~int:(1 + num_destroyed_by_plt_stub) ~float:0
  | Iintop(Icomp _) | Iintop_imm((Icomp _), _) ->
      consumes ~int:1 ~float:0
  | Istore(Single, _, _) ->
      consumes ~int:0 ~float:1
  | Icompf _ ->
      consumes ~int:0 ~float:1
  | _ -> consumes ~int:0 ~float:0

(* Calling the assembler *)

let assemble_file infile outfile =
  X86_proc.assemble_file infile outfile

let init () =
  if fp then begin
    num_available_registers.(0) <- 12
  end else
    num_available_registers.(0) <- 13
