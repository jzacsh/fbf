#!/usr/bin/env bash
#
# Non-interactively provisions a server to recieve backups. Follows guide
# described in, "Dedicated HDD Host, Given Dedicated Machine" here:
#   https://github.com/jzacsh/fbf/blob/0ca27559ad04/doc/labor.adoc#dedicated-hdd-host-given-dedicated-machine
#
# NOTE: *assumes* basic raspbian setup already done, described by,
# "Dedicated Machine, Given Unused Hardware" here:
#   https://github.com/jzacsh/fbf/blob/0ca27559ad04/doc/labor.adoc#dedicated-machine-given-unused-hardware
#
# See https://github.com/jzacsh/fbf for more.
set -euo pipefail

declare -a pkgs=(
  rsync
  rsnapshot
); declare -r pkgs

set -x

sudo apt-get install --yes "${pkgs[*]}"

exit 99 # TODO actualy write this script
