#!/usr/bin/env bash
#
#
set -euo pipefail

device="$1"; declare -r device

echo -e "[DEBUG] modding sshd! UID=$UID EUID=$EUID\t$@"

stat "$device"
# - user=$FOO; ensure have custom system user (without $HOME)
# - limit user=$FOO
# - manage AuthorizedKeysFile /etc/${FOO}.d/authorized_keys
# -   command="/path/to/script" ssh-rsa [key fingerprint== user]
# - /path/to/script should:
#  - rsync: iff dest is corresponding drive
#  - report back general monitoring logs
