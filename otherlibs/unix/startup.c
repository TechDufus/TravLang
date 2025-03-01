/**************************************************************************/
/*                                                                        */
/*                                 travlang                                  */
/*                                                                        */
/*   Xavier Leroy and Pascal Cuoq, projet Cristal, INRIA Rocquencourt     */
/*                                                                        */
/*   Copyright 1996 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <caml/mlvalues.h>
#include "winworker.h"
#include "windbug.h"

value caml_win32_process_id;

CAMLprim value caml_unix_startup(value unit)
{
  WSADATA wsaData;
  int i;
  HANDLE h;

  (void) WSAStartup(MAKEWORD(2, 0), &wsaData);
  DuplicateHandle(GetCurrentProcess(), GetCurrentProcess(),
                  GetCurrentProcess(), &h, 0, TRUE,
                  DUPLICATE_SAME_ACCESS);
  caml_win32_process_id = Val_int(h);

  caml_win32_worker_init();

  return Val_unit;
}

CAMLprim value caml_unix_cleanup(value unit)
{
  caml_win32_worker_cleanup();

  (void) WSACleanup();

  return Val_unit;
}
