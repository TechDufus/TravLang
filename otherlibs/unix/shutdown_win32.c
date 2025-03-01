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

#include <caml/mlvalues.h>
#include "caml/unixsupport.h"

static const int shutdown_command_table[] = {
  0, 1, 2
};

CAMLprim value caml_unix_shutdown(value sock, value cmd)
{
  if (shutdown(Socket_val(sock),
               shutdown_command_table[Int_val(cmd)]) == -1) {
    caml_win32_maperr(WSAGetLastError());
    caml_uerror("shutdown", Nothing);
  }
  return Val_unit;
}
