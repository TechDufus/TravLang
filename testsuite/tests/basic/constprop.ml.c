(* TEST
 flags = "-pp '${cpp} ${cppflags}'";
 travlang_filetype_flag = "-impl";
 {
   compare_programs = "false";
   bytecode;
 }{
   native;
 }
*)

(* This file has extension .ml.c because it needs to be preprocessed
   by the C preprocessor, which requires a .c extension when called
   through the C compiler
*)

(* Test constant propagation through inlining *)

(* constprop.ml is generated from constprop.mlp using
      cpp constprop.mlp > constprop.ml
*)

#define tbool(x,y) \
  (x && y, x || y, not x)

#define tint(x,y,s)                                                         \
  (-x, x + y, x - y, x * y, x / y, x mod y,                                 \
   x land y, x lor y, x lxor y,                                             \
   x lsl s, x lsr s, x asr s,                                               \
   x = y, x <> y, x < y, x <= y, x > y, x >= y,                             \
   succ x, pred y)

#define tfloat(x,y)                                                         \
  (int_of_float x,                                                          \
   x +. y, x -. y, x *. y, x /. y,                                          \
   x = y, x <> y, x < y, x <= y, x > y, x >= y)

#define tconvint(i)                                                         \
  (float_of_int i,                                                          \
   Int32.of_int i,                                                          \
   Nativeint.of_int i,                                                      \
   Int64.of_int i)

#define tconvint32(i)                                                       \
  (Int32.to_int i,                                                          \
   Nativeint.of_int32 i,                                                    \
   Int64.of_int32 i)

#define tconvnativeint(i)                                                   \
  (Nativeint.to_int i,                                                      \
   Nativeint.to_int32 i,                                                    \
   Int64.of_nativeint i)

#define tconvint64(i)                                                       \
  (Int64.to_int i,                                                          \
   Int64.to_int32 i,                                                        \
   Int64.to_nativeint i)                                                    \

#define tint32(x,y,s)                                                       \
  Int32.(neg x, add x y, sub x y, mul x y, div x y, rem x y,                \
         logand x y, logor x y, logxor x y,                                 \
         shift_left x s, shift_right x s, shift_right_logical x s,          \
         x = y, x <> y, x < y, x <= y, x > y, x >= y)

#define tnativeint(x,y,s)                                                   \
  Nativeint.(neg x, add x y, sub x y, mul x y, div x y, rem x y,            \
         logand x y, logor x y, logxor x y,                                 \
         shift_left x s, shift_right x s, shift_right_logical x s,          \
         x = y, x <> y, x < y, x <= y, x > y, x >= y)

#define tint64(x,y,s)                                                       \
  Int64.(neg x, add x y, sub x y, mul x y, div x y, rem x y,                \
         logand x y, logor x y, logxor x y,                                 \
         shift_left x s, shift_right x s, shift_right_logical x s,          \
         x = y, x <> y, x < y, x <= y, x > y, x >= y)

let do_test msg res1 res2 =
  Printf.printf "%s: %s\n" msg (if res1 = res2 then "passed" else "FAILED")

(* Hide a constant from the optimizer, preventing constant propagation *)
let hide x = List.nth [x] 0

let _ =
  begin
    let x = true and y = false in
    let xh = hide x and yh = hide y in
    do_test "booleans" (tbool(x, y)) (tbool(xh,yh))
  end;
  begin
    let x = 89809344 and y = 457455773 and s = 7 in
    let xh = hide x and yh = hide y and sh = hide s in
    do_test "integers" (tint(x, y, s)) (tint(xh,yh,sh))
  end;
  begin
    let x = 3.141592654 and y = 0.341638588598232096 in
    let xh = hide x and yh = hide y in
    do_test "floats" (tfloat(x, y)) (tfloat(xh, yh))
  end;
  begin
    let x = 781944104l and y = 308219921l and s = 3 in
    let xh = hide x and yh = hide y and sh = hide s in
    do_test "32-bit integers" (tint32(x, y, s)) (tint32(xh, yh, sh))
  end;
  begin
    let x = 1828697041n and y = -521695949n and s = 8 in
    let xh = hide x and yh = hide y and sh = hide s in
    do_test "native integers" (tnativeint(x, y, s)) (tnativeint(xh, yh, sh))
  end;
  begin
    let x = 1511491586921138079L and y = 6677538715441746158L and s = 17 in
    let xh = hide x and yh = hide y and sh = hide s in
    do_test "64-bit integers" (tint64(x, y, s)) (tint64(xh, yh, sh))
  end;
  begin
    let x = 1000807289 in
    let xh = hide x in
    do_test "integer conversions" (tconvint(x)) (tconvint(xh))
  end;
  begin
    let x = 10486393l in
    let xh = hide x in
    do_test "32-bit integer conversions" (tconvint32(x)) (tconvint32(xh))
  end;
  begin
    let x = -131134014n in
    let xh = hide x in
    do_test "native integer conversions" (tconvnativeint(x))(tconvnativeint(xh))
  end;
  begin
    let x = 531871273453404175L in
    let xh = hide x in
    do_test "64-bit integer conversions" (tconvint64(x)) (tconvint64(xh))
  end
