(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*             Sebastien Hinderer, projet Gallium, INRIA Paris            *)
(*                                                                        *)
(*   Copyright 2017 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Interface for travlangtest's configuration module *)

val arch : string
(** Architecture for the native compiler *)

val afl_instrument : bool
(** Whether AFL support has been enabled in the compiler *)

val asm : string
(** Path to the assembler *)

val cpp : string
(** Command to use to invoke the C preprocessor *)

val cppflags : string
(** Flags to pass to the C preprocessor *)

val cc : string
(** Command to use to invoke the C compiler *)

val cflags : string
(** Flags to pass to the C compiler *)

val ccomptype : string
(** Type of C compiler (msvc, cc, etc.) *)

val diff : string
(** Path to the diff tool *)

val diff_flags : string
(** Flags to pass to the diff tool *)

val shared_libraries : bool
(** [true] if shared libraries are supported, [false] otherwise *)

val libunix : bool option
(** [Some true] for unix, [Some false] for win32unix, or [None] if neither is
    built. *)

val systhreads : bool
(** Indicates whether systhreads is available. *)

val str : bool
(** Indicates whether str is available. *)

val objext : string
(** Extension of object files *)

val libext : string
(** Extension of library files *)

val asmext : string
(** Extension of assembly files *)

val system : string
(** The content of the SYSTEM Make variable *)

val travlangc_default_flags : string
(** Flags passed by default to travlangc.byte and travlangc.opt *)

val travlangopt_default_flags : string
(** Flags passed by default to travlangopt.byte and travlangopt.opt *)

val travlangsrcdir : string
(** The absolute path of the directory containing the sources of travlang *)

val flambda : bool
(** Whether flambda has been enabled at configure time *)

val flat_float_array : bool
(* Whether the compiler was configured with --enable-flat-float-array *)

val travlangdoc : bool
(** Whether travlangdoc has been enabled at configure time *)

val travlangdebug : bool
(** Whether travlangdebug has been enabled at configure time *)

val native_compiler : bool
(** Whether the native compiler has been enabled at configure time *)

val native_dynlink : bool
(** Whether support for native dynlink is available or not *)

val shared_library_cflags : string
(** Flags to use when compiling a C object for a shared library *)

val sharedobjext : string
(** Extension of shared object files *)

val csc : string
(** Path of the CSharp compiler, empty if not available *)

val csc_flags : string
(** Flags for the CSharp compiler *)

val exe : string
(** Extension of executable files *)

val mkdll : string
val mkexe : string

val bytecc_libs : string

val nativecc_libs : string

val windows_unicode : bool

val function_sections : bool
(** Whether the compiler was configured to generate
    each function in a separate section *)

val instrumented_runtime : bool
(** Whether the instrumented runtime is available *)

val frame_pointers : bool
(** Whether frame-pointers have been enabled at configure time *)

val tsan : bool
(** Whether ThreadSanitizer support has been enabled at configure time *)
