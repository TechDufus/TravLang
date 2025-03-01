#!/usr/bin/env bash
#**************************************************************************
#*                                                                        *
#*                                 travlang                                  *
#*                                                                        *
#*                 David Allsopp, travlang Labs, Cambridge.                  *
#*                                                                        *
#*   Copyright 2021 David Allsopp Ltd.                                    *
#*                                                                        *
#*   All rights reserved.  This file is distributed under the terms of    *
#*   the GNU Lesser General Public License version 2.1, with the          *
#*   special exception on linking described in the file LICENSE.          *
#*                                                                        *
#**************************************************************************

set -e

# Test whether the manual/ has been touched by this PR.

if [[ $2 = 'push' && ${11} = 'travlang/travlang' ]]; then
  # Always build the manual for pushes to travlang/travlang
  result=true
else
  # We need all the commits in the PR to be available
  . tools/ci/actions/deepen-fetch.sh
  if git diff "$MERGE_BASE..$PR_HEAD" --name-only --exit-code \
       -- manual/* > /dev/null; then
    result=false
  else
    result=true
  fi
fi

echo "Manual altered: $result"
echo "manual_changed=$result" >>"$GITHUB_OUTPUT"
