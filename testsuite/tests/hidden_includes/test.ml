(* TEST
(* This tests the -H flag.

   The basic structure is that libc depends on libb, which depends on liba.  We
   want to test a few things:

   - Compiling libc with -I liba allows the compiler to see the type definitions
     in liba and allows c.ml to reference it directly.

   - Compiling libc with -H liba allows the compiler to see the type definitions
     in liba, but doesn't allow c.ml to reference it directly.

   - If -H and -I are are passed for two different versions of liba, the -I one
     takes priority.

   - If -H is passed twice with two different versions of liba, the first takes
     priority.

   The liba_alt directory has an alternate versions of liba used for testing the
   precedence order of the includes.
*)

subdirectories = "liba liba_alt libb libc";
setup-travlangc.byte-build-env;

flags = "-I liba -nocwd";
module = "liba/a.ml";
travlangc.byte;

flags = "-I liba_alt -nocwd";
module = "liba_alt/a.ml";
travlangc.byte;

flags = "-I liba -I libb -nocwd";
module = "libb/b.ml";
travlangc.byte;
{
  (* Test hiding A completely *)
  flags = "-I libb -nocwd";
  module = "libc/c2.ml";
  setup-travlangc.byte-build-env;
  travlangc.byte;
}
{
  (* Test hiding A completely, but using it *)
  flags = "-I libb -nocwd";
  module = "libc/c1.ml";
  setup-travlangc.byte-build-env;
  travlangc_byte_exit_status = "2";
  travlangc.byte;
  compiler_reference = "${test_source_directory}/not_included.travlangc.reference";
  check-travlangc.byte-output;
}
{
  (* Test transitive use of A's cmi with -I. *)
  flags = "-I liba -I libb -nocwd";
  module = "libc/c1.ml";
  setup-travlangc.byte-build-env;
  travlangc.byte;
}
{
  (* Test transitive use of A's cmi with -H. *)
  flags = "-H liba -I libb -nocwd";
  module = "libc/c1.ml";
  setup-travlangc.byte-build-env;
  travlangc.byte;
}
{
  (* Test direct use of A cmi with -H. *)
  flags = "-H liba -I libb -nocwd";
  module = "libc/c3.ml";
  setup-travlangc.byte-build-env;
  travlangc_byte_exit_status = "2";
  travlangc.byte;
  compiler_reference =
    "${test_source_directory}/cant_reference_hidden.travlangc.reference";
  check-travlangc.byte-output;
}

(* The next four tests check that -I takes priority over -H regardless of the
   order on the command line.
*)
{
  flags = "-H liba_alt -I liba -I libb -nocwd";
  module = "libc/c1.ml";
  setup-travlangc.byte-build-env;
  travlangc.byte;
}
{
  flags = "-I liba -H liba_alt -I libb -nocwd";
  module = "libc/c1.ml";
  setup-travlangc.byte-build-env;
  travlangc.byte;
}
{
  not-windows;
  flags = "-H liba -I liba_alt -I libb -nocwd";
  module = "libc/c1.ml";
  setup-travlangc.byte-build-env;
  travlangc_byte_exit_status = "2";
  travlangc.byte;
  compiler_reference =
    "${test_source_directory}/wrong_include_order.travlangc.reference";
  check-travlangc.byte-output;
}
{
  not-windows;
  flags = "-I liba_alt -H liba -I libb -nocwd";
  module = "libc/c1.ml";
  setup-travlangc.byte-build-env;
  travlangc_byte_exit_status = "2";
  travlangc.byte;
  compiler_reference =
    "${test_source_directory}/wrong_include_order.travlangc.reference";
  check-travlangc.byte-output;
}

(* The next two tests show that earlier -Hs take priority over later -Hs *)
{
  not-windows;
  flags = "-H liba_alt -H liba -I libb -nocwd";
  module = "libc/c1.ml";
  setup-travlangc.byte-build-env;
  travlangc_byte_exit_status = "2";
  travlangc.byte;
  compiler_reference =
    "${test_source_directory}/wrong_include_order.travlangc.reference";
  check-travlangc.byte-output;
}
{
  flags = "-H liba -H liba_alt -I libb -nocwd";
  module = "libc/c1.ml";
  setup-travlangc.byte-build-env;
  travlangc.byte;
}

(* Test that a hidden `A` doesn't become visible as a result of the typechecker
   using it. *)
{
  flags = "-H liba -I libb -nocwd";
  module = "libc/c4.ml";
  setup-travlangc.byte-build-env;
  travlangc_byte_exit_status = "2";
  travlangc.byte;
  compiler_reference =
    "${test_source_directory}/hidden_stays_hidden.travlangc.reference";
  check-travlangc.byte-output;
}

(* Test that type-directed constructor disambiguation works through -H (at
   least, for now). *)
{
  flags = "-H liba -I libb -nocwd";
  module = "libc/c5.ml";
  setup-travlangc.byte-build-env;
  travlangc.byte;
}

*)
