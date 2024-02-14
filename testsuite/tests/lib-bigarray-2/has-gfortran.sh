#!/bin/sh
if ! which gfortran > /dev/null 2>&1; then
  echo "gfortran not available" > ${travlangtest_response}
  test_result=${TEST_SKIP}
elif ! grep -q '^CC=gcc' ${travlangsrcdir}/Makefile.config; then
  echo "travlang was not compiled with gcc" > ${travlangtest_response}
  test_result=${TEST_SKIP}
elif gcc --version 2>&1 | grep 'Apple clang version'; then
  echo "travlang was not compiled with gcc" > ${travlangtest_response}
  test_result=${TEST_SKIP}
else
  test_result=${TEST_PASS}
fi

exit ${test_result}
