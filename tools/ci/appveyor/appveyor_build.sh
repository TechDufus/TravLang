#!/usr/bin/env bash
#**************************************************************************
#*                                                                        *
#*                                 travlang                                  *
#*                                                                        *
#*                         Christophe Troestler                           *
#*                                                                        *
#*   Copyright 2015 Christophe Troestler                                  *
#*                                                                        *
#*   All rights reserved.  This file is distributed under the terms of    *
#*   the GNU Lesser General Public License version 2.1, with the          *
#*   special exception on linking described in the file LICENSE.          *
#*                                                                        *
#**************************************************************************

set -e

BUILD_PID=0

# This must correspond with the entry in appveyor.yml
CACHE_DIRECTORY=/cygdrive/c/projects/cache

if [[ -z $APPVEYOR_PULL_REQUEST_HEAD_COMMIT ]] ; then
  MAKE="make -j$NUMBER_OF_PROCESSORS"
else
  MAKE=make
fi

git config --global --add safe.directory '*'

function run {
    if [[ $1 = "--show" ]] ; then SHOW_CMD='true'; shift; else SHOW_CMD=''; fi
    NAME=$1
    shift
    echo "-=-=- $NAME -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    if [[ -n $SHOW_CMD ]]; then (set -x; "$@"); else "$@"; fi
    CODE=$?
    if [[ $CODE -ne 0 ]] ; then
        echo "-=-=- $NAME failed! -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        if [[ $BUILD_PID -ne 0 ]] ; then
          kill -KILL $BUILD_PID 2>/dev/null
          wait $BUILD_PID 2>/dev/null
        fi
        exit $CODE
    else
        echo "-=-=- End of $NAME -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    fi
}

# Function: set_configuration
# Takes 3 arguments
# $1:the Windows port. Recognized values: mingw, msvc and msvc64
# $2: the prefix to use to install
function set_configuration {
    case "$1" in
        cygwin*)
            dep='--disable-dependency-generation'
            man=''
        ;;
        mingw32)
            host='--host=i686-w64-mingw32'
            dep='--disable-dependency-generation'
            man=''
        ;;
        mingw64)
            host='--host=x86_64-w64-mingw32'
            dep='--disable-dependency-generation'
            man='--disable-stdlib-manpages'
        ;;
        msvc32)
            host='--host=i686-pc-windows'
            dep='--disable-dependency-generation'
            man=''
        ;;
        msvc64)
            host='--host=x86_64-pc-windows'
            # Explicitly test dependency generation on msvc64
            dep='--enable-dependency-generation'
            man=''
        ;;
    esac

    mkdir -p "$CACHE_DIRECTORY"

    local CACHE_KEY CACHE_FILE_PREFIX CACHE_FILE
    CACHE_KEY=$({ cat configure; uname; } | shasum | cut -c 1-7)
    CACHE_FILE_PREFIX="$CACHE_DIRECTORY/config.cache-$1"
    CACHE_FILE="$CACHE_FILE_PREFIX-$CACHE_KEY"

    # Remove old configure cache if the configure script or the OS
    # have changed
    if [[ ! -f "$CACHE_FILE" ]] ; then
        rm -f -- "$CACHE_FILE_PREFIX"*
    fi

    # Remove configure cache if the script has failed
    if ! ./configure --cache-file="$CACHE_FILE" $dep $build $man $host \
                     --prefix="$2" --enable-travlangtest ; then
        rm -f -- "$CACHE_FILE"
        ./configure --cache-file="$CACHE_FILE" $dep $build $man $host \
                    --prefix="$2" --enable-travlangtest
    fi

#    FILE=$(pwd | cygpath -f - -m)/Makefile.config
#    run "Content of $FILE" cat Makefile.config
}

PARALLEL_URL='https://git.savannah.gnu.org/cgit/parallel.git/plain/src/parallel'
APPVEYOR_BUILD_FOLDER=$(echo "$APPVEYOR_BUILD_FOLDER" | cygpath -f -)
FLEXDLLROOT="$PROGRAMFILES/flexdll"
travlangROOT=$(echo "$travlangROOT" | cygpath -f - -m)

if [[ $BOOTSTRAP_FLEXDLL = 'false' ]] ; then
  case "$PORT" in
    cygwin*)
      install_flexdll='false';;
    *)
      export PATH="$FLEXDLLROOT:$PATH"
      install_flexdll='true';;
  esac
else
  install_flexdll='false'
fi

case "$1" in
  install)
    mkdir -p "$CACHE_DIRECTORY"
    if [ ! -e "$CACHE_DIRECTORY/parallel-source" ] || \
       [ "$PARALLEL_URL" != "$(cat "$CACHE_DIRECTORY/parallel-source")" ] ; then
      # Download latest version directly from the repo
      curl -Ls $PARALLEL_URL -o "$CACHE_DIRECTORY/parallel"
      echo "$PARALLEL_URL" > "$CACHE_DIRECTORY/parallel-source"
    fi
    cp "$CACHE_DIRECTORY/parallel" /usr/bin
    chmod +x /usr/bin/parallel
    parallel --version
    if [[ $install_flexdll = 'true' ]] ; then
      mkdir -p "$FLEXDLLROOT"
      cd "$APPVEYOR_BUILD_FOLDER/../flexdll"
      # The objects are always built from the sources
      for f in flexdll.h flexlink.exe default*.manifest ; do
        cp "$f" "$FLEXDLLROOT/"
      done
    fi
    case "$PORT" in
      msvc*)
        echo 'eval $($APPVEYOR_BUILD_FOLDER/tools/msvs-promote-path)' \
          >> ~/.bash_profile
        ;;
    esac
    ;;
  test)
    FULL_BUILD_PREFIX="$APPVEYOR_BUILD_FOLDER/../$BUILD_PREFIX"
    run 'travlangc.opt -version' "$FULL_BUILD_PREFIX-$PORT/travlangc.opt" -version
    if [[ $PORT =~ mingw* ]] ; then
      run "Check runtime symbols" \
          "$FULL_BUILD_PREFIX-$PORT/tools/check-symbol-names" \
          $FULL_BUILD_PREFIX-$PORT/runtime/*.a \
          $FULL_BUILD_PREFIX-$PORT/otherlibs/*/lib*.a
    fi
    # The testsuite is too slow to run on AppVeyor in full. Run the dynlink
    # tests now (to include natdynlink)
    run "test dynlink $PORT" \
        $MAKE -C "$FULL_BUILD_PREFIX-$PORT/testsuite" parallel-lib-dynlink
    # Now reconfigure travlangtest to run in bytecode-only mode
    sed -i '/native_/s/true/false/' \
           "$FULL_BUILD_PREFIX-$PORT/travlangtest/travlangtest_config.ml"
    $MAKE -C "$FULL_BUILD_PREFIX-$PORT" -j travlangtest travlangtest.opt
    # And run the entire testsuite, skipping all the native-code tests
    run "test $PORT" \
        make -C "$FULL_BUILD_PREFIX-$PORT/testsuite" SHOW_TIMINGS=1 all
    run "install $PORT" $MAKE -C "$FULL_BUILD_PREFIX-$PORT" install
    if [[ $PORT = 'msvc64' ]] ; then
      run "$MAKE check_all_arches" \
           $MAKE -C "$FULL_BUILD_PREFIX-$PORT" check_all_arches
      cd "$FULL_BUILD_PREFIX-$PORT"
      # Ensure that .gitignore is up-to-date - this will fail if any untracked
      # or altered files exist. We revert the change from the bootstrap (that
      # would have failed the build earlier if necessary)
      git checkout -- boot/travlangc boot/travlanglex
      # Remove the FlexDLL sources placed earlier in the process
      rm -rf "flexdll-$FLEXDLL_VERSION"
      run --show "Check tree is tracked" test -z "$(git status --porcelain)"
      # check that the `distclean` target definitely cleans the tree
      run "$MAKE distclean" $MAKE distclean
      # Check the working tree is clean
      run --show "Check tree is tracked" test -z "$(git status --porcelain)"
      # Check that there are no ignored files
      run --show "Check tree is clean" \
        test -z "$(git ls-files --others -i --exclude-standard)"
    fi
    ;;
  *)
    cd "$APPVEYOR_BUILD_FOLDER/../$BUILD_PREFIX-$PORT"

    if [[ $PORT = 'msvc64' ]] ; then
      # Ensure that make distclean can be run from an empty tree
      run "$MAKE distclean" $MAKE distclean
    fi

    if [[ $install_flexdll = 'true' ]] ; then
      tar -xzf "$APPVEYOR_BUILD_FOLDER/flexdll.tar.gz"
      cd "flexdll-$FLEXDLL_VERSION"
      $MAKE MSVC_DETECT=0 CHAINS=${PORT%32} support
      cp -f *.obj "$FLEXDLLROOT/" 2>/dev/null || \
      cp -f *.o "$FLEXDLLROOT/"
      cd ..
    fi

    set_configuration "$PORT" "$travlangROOT"

    export TERM=ansi

    case "$BUILD_MODE" in
      world.opt)
        set -o pipefail
        # For an explanation of the sed command, see
        # https://github.com/appveyor/ci/issues/1824
        script --quiet --return --command \
          "$MAKE -C ../$BUILD_PREFIX-$PORT world.opt" \
          "../$BUILD_PREFIX-$PORT/build.log" |
            sed -e 's/\d027\[K//g' \
                -e 's/\d027\[m/\d027[0m/g' \
                -e 's/\d027\[01\([m;]\)/\d027[1\1/g'
        rm -f build.log;;
    steps)
      run "C deps: runtime" make -j64 -C runtime setup-depend
      run "C deps: win32unix" make -j64 -C otherlibs/win32unix setup-depend
      run "$MAKE world" $MAKE world
      run "$MAKE bootstrap" $MAKE bootstrap
      run "$MAKE opt" $MAKE opt
      run "$MAKE opt.opt" $MAKE opt.opt;;
    C)
      run "$MAKE world" $MAKE world
      run "$MAKE runtimeopt" $MAKE runtimeopt
      run "$MAKE -C otherlibs/systhreads libthreadsnat.lib" \
           $MAKE -C otherlibs/systhreads libthreadsnat.lib;;
    *)
      echo "Unrecognised build: $BUILD_MODE"
      exit 1
    esac

    echo DLL base addresses
    case "$PORT" in
      *32)
        ARG='-4';;
      *64)
        ARG='-8';;
    esac
    find "../$BUILD_PREFIX-$PORT" -type f \( -name \*.dll -o -name \*.so \) | \
      xargs rebase -i "$ARG"

    ;;
esac
