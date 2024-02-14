(* TEST *)
let () = set_binary_mode_out stdout true in
(* travlangtest must normalise the \r\n *)
print_string "line1\r\nline2\r\n"; flush stdout
