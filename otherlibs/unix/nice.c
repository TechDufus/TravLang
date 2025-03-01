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
#include "caml/unixsupport.h"
#include <errno.h>
#ifdef HAS_UNISTD
#include <unistd.h>
#endif

CAMLprim value caml_unix_nice(value incr)
{
  int ret;
  errno = 0;
#ifdef HAS_NICE
  ret = nice(Int_val(incr));
#else
  ret = 0;
#endif
  if (ret == -1 && errno != 0) caml_uerror("nice", Nothing);
  return Val_int(ret);
}
