#!/usr/bin/env bash
#
# NOTE: COPY/PASTED from github.com/jzacsh/yabashlib
set -euo pipefail

specDir="$(readlink -f "$1")"; shift

[ -d "$specDir" ] || exit 99

specSuite="$specDir/"*.bats
tmpDir="$specDir/.tmp/"; mkdir -p "$tmpDir"
batsDir="$tmpDir/.bats"
batsBld="$batsDir/local"
batsExec="$batsBld/bin/bats"

# Ensure bats unit testing framework is in place
[ ! -x "$batsExec" ] && {
  src_dir="$batsDir/src"

  exec 4>/dev/null
  [[ "$@" =~ --tap ]] && safefd=4 || safefd=2

  {
    echo 'Could not find local bats installation, installing now...' >&$safefd
    [ -d "$batsDir" ] && rmdir "$batsDir"
    {
      [ ! -d "$batsDir" ] &&
        git clone --quiet https://github.com/sstephenson/bats.git "$src_dir" &&
        mkdir "$batsBld" &&
        "$src_dir/install.sh" "$batsBld" &&
        [ -x "$batsExec" ]
    } >&$safefd

    [ -d "$batsDir" ] || {
      echo 'Failed to automatically install bats test framework' >&2
      exit 1
    }
  } || {
    echo 'ERROR: Failed to find or install bats testing framework' >&2
    exit 1
  }
}

# Default to pointing at spec/suite/ if it doesn't look like there are file
# args intended for bats to read directly
bats_target="$specSuite"
for (( i = 1; i <= $#; ++i  ));do
  [ -r ${!i} ] && {
    unset bats_target
    break
  }
done

mkdir -p "$tmpDir/mktmp"

# Execute all bats unit tests
SRC_DIR="$(dirname "$specDir")" \
  TMPDIR="$tmpDir/mktmp" \
  "$batsExec" $@ $bats_target
