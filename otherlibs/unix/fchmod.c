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

#include <sys/types.h>
#include <sys/stat.h>
#include <caml/fail.h>
#include <caml/mlvalues.h>
#include <caml/signals.h>
#include "caml/unixsupport.h"

#ifdef HAS_FCHMOD

CAMLprim value caml_unix_fchmod(value fd, value perm)
{
  int result;
  caml_enter_blocking_section();
  result = fchmod(Int_val(fd), Int_val(perm));
  caml_leave_blocking_section();
  if (result == -1) caml_uerror("fchmod", Nothing);
  return Val_unit;
}

#else

CAMLprim value caml_unix_fchmod(value fd, value perm)
{ caml_invalid_argument("fchmod not implemented"); }

#endif
