(* TEST
 travlanglex_flags = "-q";
*)

{
}

let ws = [' ''\t']
let nl = '\n'
let constr = ['A'-'Z']['a'-'z''A'-'Z''0'-'9''_']*
let int = ['0'-'9']+
let mnemo = ['a'-'z']['a'-'z''-']*['a'-'z']

rule seek_let_number_function = parse
| ws* "let" ws+ "number" ws* "=" ws* "function" ws* '\n'
  { () }
| [^'\n']* '\n'
  { seek_let_number_function lexbuf }

and constructors = parse
| ws* '|' ws* (constr as c) (ws* '_')? ws* "->" ws* (int as n) [^'\n']* '\n'
  { (c, int_of_string n) :: constructors lexbuf }
| ws* ";;" ws* '\n'
  { [] }

and mnemonics = parse
| ws* (int as n) ws+ '[' (mnemo as s) ']' [^'\n']* '\n'
  { (s, int_of_string n) :: mnemonics lexbuf }
| [^'\n']* '\n'
  { mnemonics lexbuf }
| eof
  { [] }

{
let travlangsrcdir = Sys.getenv "travlangsrcdir"

let travlangrun = Sys.getenv "travlangrun"

let constructors =
  let ic = open_in Filename.(concat travlangsrcdir (concat "utils" "warnings.ml")) in
  Fun.protect ~finally:(fun () -> close_in_noerr ic)
    (fun () ->
       let lexbuf = Lexing.from_channel ic in
       seek_let_number_function lexbuf;
       constructors lexbuf
    )

let mnemonics =
  let stdout = "warn-help.out" in
  let n =
    Sys.command
      Filename.(quote_command ~stdout
                  travlangrun [concat travlangsrcdir "travlangc"; "-warn-help"])
  in
  assert (n = 0);
  let ic = open_in stdout in
  Fun.protect ~finally:(fun () -> close_in_noerr ic)
    (fun () ->
       let lexbuf = Lexing.from_channel ic in
       mnemonics lexbuf
    )

let mnemonic_of_constructor s =
  String.map (function '_' -> '-' | c -> Char.lowercase_ascii c) s

let deprecated_warnings = function
  | 3 | 25 | 31 -> true
  | _  -> false

let () =
  List.iter (fun (s, n) ->
      let f (c, m) = mnemonic_of_constructor c = s && n = m in
      match List.exists f constructors, deprecated_warnings n with
      | true, false -> ()
      | false, true -> ()
      | false, false ->
        Printf.printf "Could not find constructor corresponding to mnemonic %S (%d)\n%!" s n
      | true, true ->
        Printf.printf "Found constructor for deprecated warnings %S (%d)\n%!" s n
    ) mnemonics

let _ =
  List.fold_left (fun first (c, m) ->
      if List.mem (mnemonic_of_constructor c, m) mnemonics then first
      else begin
        if first then print_endline "Constructors without associated mnemonic:";
        print_endline c;
        false
      end
    ) true constructors
}
