/**************************************************************************/
/*                                                                        */
/*                                 travlang                                  */
/*                                                                        */
/*    Contributed by Tracy Camp, PolyServe Inc., <campt@polyserve.com>    */
/*                  Further improvements by Reed Wilson                   */
/*                                                                        */
/*   Copyright 2002 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#include <errno.h>
#include <fcntl.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include "caml/unixsupport.h"
#include <stdio.h>
#include <caml/signals.h>

#ifndef INVALID_SET_FILE_POINTER
#define INVALID_SET_FILE_POINTER (-1)
#endif

/* Sets handle h to a position based on gohere */
/* output, if set, is changed to the new location */

CAMLprim value caml_unix_lockf(value fd, value cmd, value span)
{
  CAMLparam3(fd, cmd, span);
  OVERLAPPED overlap;
  intnat l_len;
  HANDLE h;
  LARGE_INTEGER cur_position;
  LARGE_INTEGER beg_position;
  LARGE_INTEGER lock_len;
  LARGE_INTEGER zero = {{0, 0}};
  DWORD err = NO_ERROR;

  h = Handle_val(fd);

  l_len = Long_val(span);

  /* No matter what, we need the current position in the file */
  if (!SetFilePointerEx(h, zero, &cur_position, FILE_CURRENT)) {
    caml_win32_maperr(GetLastError());
    caml_uerror("lockf", Nothing);
  }

  /* All unused fields must be set to zero */
  memset(&overlap, 0, sizeof(overlap));

  if(l_len == 0) {
    /* Lock from cur to infinity */
    lock_len.QuadPart = -1;
    overlap.OffsetHigh = cur_position.HighPart;
    overlap.Offset     = cur_position.LowPart ;
  }
  else if(l_len > 0) {
    /* Positive file offset */
    lock_len.QuadPart = l_len;
    overlap.OffsetHigh = cur_position.HighPart;
    overlap.Offset     = cur_position.LowPart ;
  }
  else {
    /* Negative file offset */
    lock_len.QuadPart = - l_len;
    if (lock_len.QuadPart > cur_position.QuadPart) {
      errno = EINVAL;
      caml_uerror("lockf", Nothing);
    }
    beg_position.QuadPart = cur_position.QuadPart - lock_len.QuadPart;
    overlap.OffsetHigh = beg_position.HighPart;
    overlap.Offset     = beg_position.LowPart ;
  }

  switch(Int_val(cmd)) {
  case 0: /* F_ULOCK - unlock */
    if (! UnlockFileEx(h, 0,
                       lock_len.LowPart, lock_len.HighPart, &overlap))
      err = GetLastError();
    break;
  case 1: /* F_LOCK - blocking write lock */
    caml_enter_blocking_section();
    if (! LockFileEx(h, LOCKFILE_EXCLUSIVE_LOCK, 0,
                     lock_len.LowPart, lock_len.HighPart, &overlap))
      err = GetLastError();
    caml_leave_blocking_section();
    break;
  case 2: /* F_TLOCK - non-blocking write lock */
    if (! LockFileEx(h, LOCKFILE_FAIL_IMMEDIATELY | LOCKFILE_EXCLUSIVE_LOCK, 0,
                     lock_len.LowPart, lock_len.HighPart, &overlap))
      err = GetLastError();
    break;
  case 3: /* F_TEST - check whether a write lock can be obtained */
    /*  I'm doing this by acquiring an immediate write
     * lock and then releasing it. It is not clear that
     * this behavior matches anything in particular, but
     * it is not clear the nature of the lock test performed
     * by travlang (unix) currently. */
    if (LockFileEx(h, LOCKFILE_FAIL_IMMEDIATELY | LOCKFILE_EXCLUSIVE_LOCK, 0,
                   lock_len.LowPart, lock_len.HighPart, &overlap)) {
      UnlockFileEx(h, 0, lock_len.LowPart, lock_len.HighPart, &overlap);
    } else {
      err = GetLastError();
    }
    break;
  case 4: /* F_RLOCK - blocking read lock */
    caml_enter_blocking_section();
    if (! LockFileEx(h, 0, 0,
                     lock_len.LowPart, lock_len.HighPart, &overlap))
      err = GetLastError();
    caml_leave_blocking_section();
    break;
  case 5: /* F_TRLOCK - non-blocking read lock */
    if (! LockFileEx(h, LOCKFILE_FAIL_IMMEDIATELY, 0,
                     lock_len.LowPart, lock_len.HighPart, &overlap))
      err = GetLastError();
    break;
  default:
    errno = EINVAL;
    caml_uerror("lockf", Nothing);
  }
  if (err != NO_ERROR) {
    caml_win32_maperr(err);
    caml_uerror("lockf", Nothing);
  }
  CAMLreturn(Val_unit);
}
