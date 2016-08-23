#!/usr/bin/env bash
#
# Mock labor needed by end-users, after both client/server are established.
set -euo pipefail

export TMPDIR="$(readlink -f "$TMP_E2E_DIR")"
ssh-keygen -N '' -f "$E2E_SSHKEY"
sed -i 's/'"$(whoami)"'/vagrant/g' "$E2E_SSHKEY"{,.pub}
sed -i 's/'"$(uname -n)"'/client/g' "$E2E_SSHKEY"{,.pub}
sshClientConf="$(mktemp --tmpdir  ssh-config_XXXXXX.txt)"
declare -r sshClientConf
trap "rm "$sshClientConf"" EXIT
cat > "$sshClientConf" <<EOF_SSHCONF
# Headless key as parallel for a person's regular access to their machine. 
Host backupreceptacle
  Hostname 10.0.0.12
  User vagrant
  IdentityFile ~/.ssh/user-key
  StrictHostKeyChecking no
EOF_SSHCONF
chmod -c 600 "$E2E_SSHKEY"
"$BIN_DIR"/vagrant-scp.sh -p "$sshClientConf"  client:.ssh/config
"$BIN_DIR"/vagrant-scp.sh -p "$E2E_SSHKEY"     client:.ssh/user-key
"$BIN_DIR"/vagrant-scp.sh -p "$E2E_SSHKEY".pub client:.ssh/user-key.pub
"$BIN_DIR"/vagrant-scp.sh -p "$E2E_SSHKEY".pub receptacle:authorized_keys_pub_tmp

vagrantSshConfig="$(mktemp --tmpdir  ssh-to-receptacle_XXXXXX.txt)"
declare -r vagrantSshConfig
trap "rm "$vagrantSshConfig"" EXIT
vagrant ssh-config > "$vagrantSshConfig"
ssh -t -F "$vagrantSshConfig" receptacle '
  echo >> .ssh/authorized_keys &&
    cat >> .ssh/authorized_keys < authorized_keys_pub_tmp &&
    rm -v authorized_keys_pub_tmp &&
    echo >> .ssh/authorized_keys
'
