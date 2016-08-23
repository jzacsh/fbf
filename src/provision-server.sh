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

declare -r backerName="${1:-backer}"

sudo useradd --system --create-home "$backerName"
usrId="$(sudo id --user "$backerName")"; declare -r usrId
grpId="$(sudo id --group "$backerName")"; declare -r grpId
homeDir="$(
  grep --extended-regexp ^"$backerName" /etc/passwd |
    cut --fields 6 --delimiter ':'
)"; declare -r homeDir

declare -r privateTmp="$homeDir"/tmp.backerconfs
sudo mkdir "$privateTmp"
sudo chown --recursive "$backerName":"$backerName" "$privateTmp"
sudo chmod 7750 "$privateTmp"
sudo cp /etc/fstab{,.orig-"$(date --iso-8601=d)"}
sudo cat >> /etc/fstab <<EOF_FSTAB
# Auto-generated, $(date --iso-8601=ns), by https://github.com/jzacsh/fbf
tmpfs $privateTmp tmpfs defaults,uid=999,gid=996,size=10K,mode=7770 0 0
EOF_FSTAB
sudo mount "$privateTmp"

#TODO come back here to reconsider HDD considerations; for now we pretend
#/mnt/backuphdds/terraspin is an already mounted HDD, because auto-HDD plugging
#isn't written yet (see for doc/remotedrivedaemon.adoc its plans)

#TODO install software from local clone of repo (eg: foo.template files?)

declare -a pkgs=(
  rsync
  rsnapshot
); declare -r pkgs

sudo apt-get install --yes "${pkgs[*]}"

sudo systemctl enable rsync.service
