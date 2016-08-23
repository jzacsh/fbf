#!/usr/bin/env bash
#
# SCP a file into a running vagrant VM
set -xeuo pipefail

tmpConf="$(mktemp --tmpdir  vagrant_scp_ssh-config_XXXXXXX.txt)"
trap "rm "$tmpConf"" EXIT
vagrant ssh-config > "$tmpConf"
scp -F "$tmpConf" $@
