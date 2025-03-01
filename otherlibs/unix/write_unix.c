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

#include <errno.h>
#include <string.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/signals.h>
#include <caml/bigarray.h>
#include "caml/unixsupport.h"

#ifndef EAGAIN
#define EAGAIN (-1)
#endif
#ifndef EWOULDBLOCK
#define EWOULDBLOCK (-1)
#endif

CAMLprim value caml_unix_write(value fd, value buf, value vofs, value vlen)
{
  CAMLparam1(buf);
  long ofs, len, written;
  int numbytes, ret;
  char iobuf[UNIX_BUFFER_SIZE];

  ofs = Long_val(vofs);
  len = Long_val(vlen);
  written = 0;
  while (len > 0) {
    numbytes = len > UNIX_BUFFER_SIZE ? UNIX_BUFFER_SIZE : len;
    memmove (iobuf, &Byte(buf, ofs), numbytes);
    caml_enter_blocking_section();
    ret = write(Int_val(fd), iobuf, numbytes);
    caml_leave_blocking_section();
    if (ret == -1) {
      if ((errno == EAGAIN || errno == EWOULDBLOCK) && written > 0) break;
      caml_uerror("write", Nothing);
    }
    written += ret;
    ofs += ret;
    len -= ret;
  }
  CAMLreturn(Val_long(written));
}

CAMLprim value caml_unix_write_bigarray(value fd, value vbuf,
                                        value vofs, value vlen, value vsingle)
{
  CAMLparam5(fd, vbuf, vofs, vlen, vsingle);
  intnat ofs, len, written, ret;
  void *buf;

  buf = Caml_ba_data_val(vbuf);
  ofs = Long_val(vofs);
  len = Long_val(vlen);
  written = 0;
  caml_enter_blocking_section();
  while (len > 0) {
    ret = write(Int_val(fd), (char *) buf + ofs, len);
    if (ret == -1) {
      if ((errno == EAGAIN || errno == EWOULDBLOCK) && written > 0) break;
      caml_leave_blocking_section();
      caml_uerror("write_bigarray", Nothing);
    }
    written += ret;
    ofs += ret;
    len -= ret;
    if (Bool_val(vsingle)) break;
  }
  caml_leave_blocking_section();
  CAMLreturn(Val_long(written));
}

/* When an error occurs after the first loop, caml_unix_write reports the
   error and discards the number of already written characters.
   In this case, it would be better to discard the error and return the
   number of bytes written, since most likely, caml_unix_write will be call
   again, and the error will be reproduced and this time will be reported.
   This problem is avoided in caml_unix_single_write, which is faithful to the
   Unix system call. */

CAMLprim value caml_unix_single_write(value fd, value buf, value vofs,
                                      value vlen)
{
  CAMLparam1(buf);
  long ofs, len;
  int numbytes, ret;
  char iobuf[UNIX_BUFFER_SIZE];

  ofs = Long_val(vofs);
  len = Long_val(vlen);
  ret = 0;
  if (len > 0) {
    numbytes = len > UNIX_BUFFER_SIZE ? UNIX_BUFFER_SIZE : len;
    memmove (iobuf, &Byte(buf, ofs), numbytes);
    caml_enter_blocking_section();
    ret = write(Int_val(fd), iobuf, numbytes);
    caml_leave_blocking_section();
    if (ret == -1) caml_uerror("single_write", Nothing);
  }
  CAMLreturn(Val_int(ret));
}
