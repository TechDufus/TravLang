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

#include <caml/fail.h>
#include <caml/mlvalues.h>
#include "caml/unixsupport.h"

#ifdef HAS_SOCKETS

#include <sys/socket.h>

CAMLprim value caml_unix_listen(value sock, value backlog)
{
  if (listen(Int_val(sock), Int_val(backlog)) == -1)
    caml_uerror("listen", Nothing);
  return Val_unit;
}

#else

CAMLprim value caml_unix_listen(value sock, value backlog)
{ caml_invalid_argument("listen not implemented"); }

#endif
