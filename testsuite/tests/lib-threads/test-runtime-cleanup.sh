#!/bin/sh
case "$travlangRUNPARAM" in
  c=1|c=1,*|*,c=1|*,c=1,*)
    echo "runtime cleans up at exit" > ${travlangtest_response};
    exit ${TEST_SKIP};;
  *) exit ${TEST_PASS};;
esac
