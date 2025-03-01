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
#include <caml/signals.h>
#include "caml/unixsupport.h"

#ifdef HAS_SOCKETS

#include "caml/socketaddr.h"

CAMLprim value caml_unix_connect(value socket, value address)
{
  int retcode;
  union sock_addr_union addr;
  socklen_param_type addr_len;

  caml_unix_get_sockaddr(address, &addr, &addr_len);
  caml_enter_blocking_section();
  retcode = connect(Int_val(socket), &addr.s_gen, addr_len);
  caml_leave_blocking_section();
  if (retcode == -1) caml_uerror("connect", Nothing);
  return Val_unit;
}

#else

CAMLprim value caml_unix_connect(value socket, value address)
{ caml_invalid_argument("connect not implemented"); }

#endif
