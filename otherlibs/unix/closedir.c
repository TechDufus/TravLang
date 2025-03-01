/**************************************************************************/
/*                                                                        */
/*                                 travlang                                  */
/*                                                                        */
/*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 1996 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/signals.h>
#include "caml/unixsupport.h"
#include <errno.h>
#include <sys/types.h>
#ifdef HAS_DIRENT
#include <dirent.h>
#else
#include <sys/dir.h>
#endif

CAMLprim value caml_unix_closedir(value vd)
{
  CAMLparam1(vd);
  DIR * d = DIR_Val(vd);
  if (d == (DIR *) NULL) caml_unix_error(EBADF, "closedir", Nothing);
  caml_enter_blocking_section();
  closedir(d);
  caml_leave_blocking_section();
  DIR_Val(vd) = (DIR *) NULL;
  CAMLreturn(Val_unit);
}
