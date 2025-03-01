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

#include <string.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/signals.h>
#include <caml/bigarray.h>
#include "caml/unixsupport.h"

CAMLprim value caml_unix_read(value fd, value buf, value ofs, value len)
{
  CAMLparam1(buf);
  long numbytes;
  int ret;
  char iobuf[UNIX_BUFFER_SIZE];

  numbytes = Long_val(len);
  if (numbytes > UNIX_BUFFER_SIZE) numbytes = UNIX_BUFFER_SIZE;
  caml_enter_blocking_section();
  ret = read(Int_val(fd), iobuf, (int) numbytes);
  caml_leave_blocking_section();
  if (ret == -1) caml_uerror("read", Nothing);
  memmove (&Byte(buf, Long_val(ofs)), iobuf, ret);
  CAMLreturn(Val_int(ret));
}

CAMLprim value caml_unix_read_bigarray(value fd, value vbuf,
                                       value vofs, value vlen)
{
  CAMLparam4(fd, vbuf, vofs, vlen);
  intnat ofs, len, ret;
  void *buf;

  buf = Caml_ba_data_val(vbuf);
  ofs = Long_val(vofs);
  len = Long_val(vlen);
  caml_enter_blocking_section();
  ret = read(Int_val(fd), (char *) buf + ofs, len);
  caml_leave_blocking_section();
  if (ret == -1) caml_uerror("read_bigarray", Nothing);
  CAMLreturn(Val_long(ret));
}
