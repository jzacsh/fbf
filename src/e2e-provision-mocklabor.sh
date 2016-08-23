#!/usr/bin/env bash
#
# Non-interactive provision script, for automated testing only.
#
# Intended to mock the one-time manual labor expected of any owner of a
# raspberry pi, described under "Dedicated Machine, Given Unused Hardware":
#   https://github.com/jzacsh/fbf/blob/0ca27559ad04/doc/labor.adoc#dedicated-machine-given-unused-hardware
#
# See https://github.com/jzacsh/fbf for more.
set -euo pipefail

for act in up{date,grade,date}; do
  sudo apt-get --yes "$act" || exit 1
done

#TODO install clone of this local repo (fbf)
