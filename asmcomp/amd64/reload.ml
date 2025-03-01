# 2 "asmcomp/amd64/reload.ml"
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

open Cmm
open Reg
open Mach

(* Reloading for the AMD64 *)

(* Summary of instruction set constraints:
   "S" means either stack or register, "R" means register only.
   Operation                    Res     Arg1    Arg2
     Imove                      R       S
                             or S       R
     Iconst_int                 S if 32-bit signed, R otherwise
     Iconst_float               R
     Iconst_symbol (not PIC)    S
     Iconst_symbol (PIC)        R
     Icall_ind                          R
     Itailcall_ind                      R
     Iload                      R       R       R
     Istore                             R       R
     Iintop(Icomp)              R       R       S
                            or  R       S       R
     Iintop(Imul|Idiv|Imod)     R       R       S
     Iintop(Imulh)              R       R       S
     Iintop(shift)              S       S       R
     Iintop(others)             R       R       S
                            or  S       S       R
     Iintop_imm(Iadd, n)/lea    R       R
     Iintop_imm(Imul, n)        R       R
     Iintop_imm(Icomp, n)       R       S
     Iintop_imm(others)         S       S
     Inegf...Idivf              R       R       S
     Ifloatofint                R       S
     Iintoffloat                R       S
     Ispecific(Ilea)            R       R       R
     Ispecific(Ifloatarithmem)  R       R       R

   Conditional branches:
     Iinttest                           S       R
                                    or  R       S
     Ifloattest                         R       S    (or  S R if swapped test)
     other tests                        S
*)

let stackp r =
  match r.loc with
    Stack _ -> true
  | _ -> false

class reload = object (self)

inherit Reloadgen.reload_generic as super

method! reload_operation op arg res =
  match op with
  | Iintop(Iadd|Isub|Iand|Ior|Ixor|Icheckbound) ->
      (* One of the two arguments can reside in the stack, but not both *)
      if stackp arg.(0) && stackp arg.(1)
      then ([|arg.(0); self#makereg arg.(1)|], res)
      else (arg, res)
  | Iintop(Icomp _) ->
      (* The result must be a register (PR#11803) *)
      let res = self#makeregs res in
      (* One of the two arguments can reside in the stack, but not both *)
      if stackp arg.(0) && stackp arg.(1)
      then ([|arg.(0); self#makereg arg.(1)|], res)
      else (arg, res)
  | Iintop_imm(Iadd, _) when arg.(0).loc <> res.(0).loc ->
      (* This add will be turned into a lea; args and results must be
         in registers *)
      super#reload_operation op arg res
  | Iintop_imm(Imul, _) ->
      (* The result (= the argument) must be a register (#10626) *)
      if stackp arg.(0)
      then (let r = self#makereg arg.(0) in ([|r|], [|r|]))
      else (arg, res)
  | Iintop_imm(Icomp _, _) ->
      (* The result must be in a register (PR#11803) *)
      (arg, self#makeregs res)
  | Iintop(Imulh | Idiv | Imod | Ilsl | Ilsr | Iasr)
  | Iintop_imm(_, _) ->
      (* The argument(s) and results can be either in register or on stack *)
      (* Note: Imulh, Idiv, Imod: arg(0) and res(0) already forced in regs
               Ilsl, Ilsr, Iasr: arg(1) already forced in regs *)
      (arg, res)
  | Iintop(Imul) | Iaddf | Isubf | Imulf | Idivf ->
      (* First argument (= result) must be in register, second arg
         can reside in the stack *)
      if stackp arg.(0)
      then (let r = self#makereg arg.(0) in ([|r; arg.(1)|], [|r|]))
      else (arg, res)
  | Ifloatofint | Iintoffloat ->
      (* Result must be in register, but argument can be on stack *)
      (arg, (if stackp res.(0) then [| self#makereg res.(0) |] else res))
  | Iconst_int n ->
      if n <= 0x7FFFFFFFn && n >= -0x80000000n
      then (arg, res)
      else super#reload_operation op arg res
  | Iconst_symbol _ ->
      if !Clflags.pic_code || !Clflags.dlcode || Arch.win64
      then super#reload_operation op arg res
      else (arg, res)
  | _ -> (* Other operations: all args and results in registers *)
      super#reload_operation op arg res

method! reload_test tst arg =
  match tst with
    Iinttest _ ->
      (* One of the two arguments can reside on stack *)
      if stackp arg.(0) && stackp arg.(1)
      then [| self#makereg arg.(0); arg.(1) |]
      else arg
  | Ifloattest (CFlt | CFnlt | CFle | CFnle) ->
      (* Cf. emit.mlp: we swap arguments in this case *)
      (* First argument can be on stack, second must be in register *)
      if stackp arg.(1)
      then [| arg.(0); self#makereg arg.(1) |]
      else arg
  | Ifloattest (CFeq | CFneq | CFgt | CFngt | CFge | CFnge) ->
      (* Second argument can be on stack, first must be in register *)
      if stackp arg.(0)
      then [| self#makereg arg.(0); arg.(1) |]
      else arg
  | _ ->
      (* The argument(s) can be either in register or on stack *)
      arg

end

let fundecl f num_stack_slots =
  (new reload)#fundecl f num_stack_slots
