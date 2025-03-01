# Introduction

This documents how to run the travlang compiler test suite. To learn how to
write tests using travlangtest, read [travlangTEST.org](./travlangTEST.org).

## Context

The testsuite of the travlang compiler consists of a series of programs
that are compiled and executed. The output of their compilation and
execution is compared to expected outputs.

Before the introduction of travlangtest, the tests were driven by a set of
makefiles which were responsible for compiling and running the test
programs, and verifying that the compilation and execution outputs were
matching the expected ones.

In this set-up, the precise information about how exactly one test
should be compiled was separated from the test itself. It was stored
somewhere in the makefiles, interleaved with the recipes to actually
compile and run the test. Thus, given one test, it was not easy to
determine exactly how this test was supposed to be compiled and run.

## Purpose

The travlangtest tool has been introduced to replace most of the makefiles
logic. It takes a test program as its input and derives from annotations
stored as a special comment at the beginning of the program the exact
way to compile and run it. Thus the test-specific metadata are stored in
the test file itself and clearly separated from the machinery required
to perform the actual tasks, which is centralized in the travlangtest tool.

## Constraints

It may look odd at first glance to write the tool used to test the
compiler in its target language. There are, however, parts of the
compiler and the standard library that are already tested in a way,
namely those used to compile the compiler itself. Therefore, these
components can be considered more trustworthy than those that have not
yet been used and that's why travlangtest relies only on the part of the
standard library that has been used to develop the compiler itself.

This excludes for instance the use of the Unix and Str libraries.

# Initial set-up

travlangtest needs to know two things:

1. Where the sources of the travlang compiler to test are located. This is
determined while travlang is built. The default location can be overridden
by defining the `travlangSRCDIR` environment variable.

2. Which directory to use to build tests. The default value for this is
`"travlangtest"` under `Filename.get_temp_dir_name()`. This value can be
overridden by defining the `travlangTESTDIR` environment variable.

# Running tests

(all the commands below are assumed to be run from
`travlangSRCDIR/testsuite`)

From here, one can:

## Run all tests: `make all`

This runs the complete testsuite. This includes the "legacy" tests that
still use the makefile-based infrastructure and the "new" tests that
have been migrated to use travlangtest.

## Run legacy tests: `make legacy`

## Run new tests: `make new`

## Run tests manually

It is convenient to have the following travlangtest script in a directory
appearing in `PATH`, like `~/bin`:

```sh
#!/bin/sh
TERM=dumb travlangRUNPARAM= /path/to/travlang/sources/travlangtest/travlangtest $*
```

Once this file has been made executable, one can for instance run:

```sh
travlangtest tests/basic-io/wc.ml
```

As can be seen, travlangtest's output looks similar to the legacy format.

This is to make the transition between the makefile-based infrastructure
and travlangtest as smooth as possible. Once all the tests will have been
migrated to travlangtest, it will become possible to change this output
format.

The details of what exactly has been tested can be found in
`${travlangTESTDIR}/tests/basic-io/wc/wc.log`

One can then examine `tests/basic-io/wc.ml` to see how the file had to
be annotated to produce such a result.

Many other tests have already been migrated and it may be useful to see
how the test files have been annotated. the command

```sh
find tests -name '*travlangtests*' | xargs cat
```

gives a list of tests that have been modified and can therefore be used
as starting points to understand what travlangtest can do.

# Migrating tests from makefiles to travlangtest

It may be a good idea to run `make new` from the `testsuite` directory
before starting to migrate tests. This will show how many "new" tests
there already are.

Then, when running `make new` after migrating _n_ tests, the number of
new tests reported by `make new` should have increased by _n_.

travlang's testsuite is divided into directories, each of them containing
one or several tests, which can each consist of one or several files.

Thus, the directory is the smallest unit that can be migrated.

To see which directories still need to be migrated, do:

```sh
find tests -name 'Makefile'
```

In other words, the directories that still need to be migrated are the
subdirectories of `testsuite/tests` that still contain a Makefile.

Once you know which directory you want to migrate, say `foo`, here is
what you should do:

Read `foo/Makefile` to see how many tests the directory contains and how
they are compiled. If the makefile only includes other makefiles and
does not define any variable, then it means that nothing special has to
be done to compile or run the tests.

You can also run the tests of this directory with the legacy framework,
to see exactly how they are compiled and executed. To do so, use the
following command from the testsuite directory:

```sh
make --trace DIR=tests/foo
```

(You may want to log the output of this command for future reference.)

For each test, annotate its main file with a test block, i.e. a comment
that looks like this:

```travlang
(* TEST
  Optional variable assignments and tests
*)
```

In particular, if the test's main file is foo.ml and the test uses
modules `m1.ml` and `m2.ml`, the test block will look like this:

```travlang
(* TEST
  modules = "m1.ml m2.ml";
*)
```

And if the test consists of a single file `foo.ml` that needs to be run
under the top-level, then its test block will look like this:

```travlang
(* TEST
  toplevel;
*)
```

Or, if there are two reference files for that test and the name of one
of them contains "principal", then it means the file should be tested
with the top-level, without and with the `-principal` option. This is
expressed as follows:

```travlang
(* TEST
  toplevel;
  include principal;
  toplevel;
*)
```

Lines starting with stars indicate which tests to run. If no test is
specified, then the tests that are enabled by default are used, namely
to compile and run the test program in both bytecode and native code
(roughly speaking).

Once your test has been annotated, run `travlangtest` on it and see whether
it passes or fails. If it fails, see the log file to understand why and
make the necessary adjustments until all the tests pass.

The adjustments will mostly consist in renaming reference files and
updating their content.

Note that there are different types of reference files, those for
compiler output and those for program output.

To make sure the migration has been done correctly, you can compare the
commands used to compile the programs in travlangtest's log file to those
obtained with `make --trace`. Beware that the commands used to compare
an obtained result to an expected one will not show up in travlangtest's
log file.

Once this has been done for all tests, create a file called `travlangtests`
(mark the final _s_!) with the names of all the files that have been
annotated for travlangtest, one per line.

Finally, `git rm` the Makefile and run `make new` from the testsuite
directory to make sure the number of new tests has increased as
expected.
