#!/bin/sh

# This script is related to the 'recvfrom_linux.ml' test.

uname="$(uname -s)"
if [ "$uname" = "Linux" ]; then

# Workaround: the tests that come after this script
# (bytecode and native) depend on stdout redirection, but
# running a script sets both of those to the empty string.
# See https://caml.inria.fr/mantis/view.php?id=7910
  cat > "$travlangtest_response" <<EOF
-stdout
-stderr
EOF

  exit ${TEST_PASS}
else
  echo "$uname" > "$travlangtest_response"
  exit ${TEST_SKIP}
fi
