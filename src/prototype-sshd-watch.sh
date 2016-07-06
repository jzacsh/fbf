#!/usr/bin/env bash
#
# Prototype of sshd-modifying daemon
set -euo pipefail

dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"; declare -r dir
mod_sshd="$dir"/prototype-sshd-mod.sh; declare -r mod_sshd
[ -x "$mod_sshd" ]

exec >> "$dir"/debug.log
exec 2>&1

# TODO replace this with call to `udisks2`
find /dev/disk/by-id/ -mindepth 1 -maxdepth 1 -name 'usb-*' -print |
  grep --invert-match --extended-regexp '\-part.$' |
  sort | uniq |
  while read dev; do su - jzacsh -c ""$mod_sshd" '$dev'"; done
