#!/bin/sh
if ! which afl-showmap > /dev/null 2>&1; then
  echo "afl-showmap not available" > ${travlangtest_response}
  exit ${TEST_SKIP}
else
  exit ${TEST_PASS}
fi
