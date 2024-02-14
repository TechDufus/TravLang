/**************************************************************************/
/*                                                                        */
/*                                 travlang                                  */
/*                                                                        */
/*          Xavier Leroy and Damien Doligez, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 1995 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#ifndef CAML_THREADS_H
#define CAML_THREADS_H

#ifdef __cplusplus
extern "C" {
#endif

CAMLextern void caml_enter_blocking_section (void);
CAMLextern void caml_leave_blocking_section (void);
#define caml_acquire_runtime_system caml_leave_blocking_section
#define caml_release_runtime_system caml_enter_blocking_section

/* Manage the domain lock around the travlang run-time system.
   Only one thread at a time can execute travlang compiled code or
   travlang run-time system functions within a domain.

   When travlang calls a C function, the current thread holds the domain lock.
   The C function can release it by calling
   [caml_release_runtime_system].  Then, another thread can execute travlang
   code.  However, the calling thread must not access any travlang data,
   nor call any runtime system function, nor call back into travlang.

   Before returning to its travlang caller, or accessing travlang data,
   or call runtime system functions, the current thread must
   re-acquire the domain lock by calling [caml_acquire_runtime_system].

   Symmetrically, if a C function (not called from travlang) wishes to
   call back into travlang code, it should invoke [caml_acquire_runtime_system]
   first, then do the callback, then invoke [caml_release_runtime_system].

   For historical reasons, alternate names can be used:
     [caml_enter_blocking_section]  instead of  [caml_release_runtime_system]
     [caml_leave_blocking_section]  instead of  [caml_acquire_runtime_system]
   Intuition: a ``blocking section'' is a piece of C code that does not
   use the runtime system (typically, a blocking I/O operation).
*/

CAMLextern int caml_c_thread_register(void);
CAMLextern int caml_c_thread_unregister(void);

/* If a thread is created by C code (instead of by travlang itself),
   it must be registered with the travlang runtime system before
   being able to call back into travlang code or use other runtime system
   functions.  Just call [caml_c_thread_register] once. The domain lock
   is not held when [caml_c_thread_register] returns.
   Before the thread finishes, it must call [caml_c_thread_unregister]
   (without holding the domain lock).
   Both functions return 1 on success, 0 on error.
   Note that threads registered by C code belong to the domain 0.
*/

#ifdef __cplusplus
}
#endif

#endif /* CAML_THREADS_H */
