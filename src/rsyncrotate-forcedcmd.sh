#!/usr/bin/env bash
set -euo pipefail

declare -r mntRoot=/mnt/backuphdds/terraspin
declare -r tmpfsDir=~backer/tmp.backerconfs
declare -r baseConf=~backer/rsnapshot.conf.template
declare -r rrsyncExec=~backer/rrsync

#############################################################
# Local helpers, nothing run here... ########################
_log() ( # logs *must* go to stder, otherwise rsync gets confused
  local tag="$1" msg="$2"; shift 2
  printf '[%s] %s: '"$msg" "$(date --iso-8601=ns)" "$tag" "$@" >&2
)
die() ( local msg="$1"; shift; _log ERROR "$msg" "$@"; exit 1; )
wrn() ( local msg="$1"; shift; _log WARN  "$msg" "$@"; )
log() ( local msg="$1"; shift; _log INFO  "$msg" "$@"; )
isWriteableDir() ( { [ -w "$1" ] && [ -d "$1" ]; } )
isPush() ( [ "${SSH_ORIGINAL_COMMAND/--sender/}" = "$SSH_ORIGINAL_COMMAND" ]; )

declare -r sshPrint="$1"
[ -n "${sshPrint/ */}" ] ||
  die 'Bug: bad .ssh/authorized_keys\nrequire fingerprint as first arg!\n'

declare -r requestId="$$"."$sshPrint"
listConfs() ( find "$tmpfsDir"/ -name '*'"$requestId"'*' -print; )

cleanupTemps() ( # non-critical cleanup
  listConfs | while read cf; do
    log 'Removing custom config:\n\t%s\n' "$(rm -v "$cf")"
  done
)

isPidFileOurs=0
catchExit() (
  [ "$isPidFileOurs" -eq 0 ] || echo -n > "$pidFile"

  [ "$(listConfs | wc -l)" != 0 ] || return 0

  wrn 'Caught dirty EXIT, cleaning up...\n'
  cleanupTemps
)
trap catchExit EXIT

#############################################################
# Start setup and sanity checks #############################
[ -n "${SSH_ORIGINAL_COMMAND/ *}" ] ||
   die 'Login not allowed; found empty $SSH_ORIGINAL_COMMAND\n'

[ "${SSH_ORIGINAL_COMMAND/rsync\ --server/}" != "$SSH_ORIGINAL_COMMAND" ] ||
   die 'Only rsync to --server is allowed\n'

lowInterval="$(
  grep --color=none --extended-regexp '^retain\t*' "$baseConf" |
    sed --expression 's|^retain\t*||g' |
    sed --expression 's|\t*[[:digit:]]$||g' |
    head --lines 1
)" || die 'could not scrape smallest interval from\n\t"%s"\n' "$baseConf"
declare -r lowInterval

[ -x "$rrsyncExec" ] || die \
  'Cannot run without restricted rsync exec, expected:\n\t%s\n' "$rrsyncExec"

isWriteableDir "$mntRoot" ||
  die 'writeable drive not available:\n\t%s\n' "$mntRoot"

declare -r snapshotRoot="$mntRoot"/auto-"$sshPrint"/
mkdir --verbose --parents "$snapshotRoot" >&2 ||
  die 'could not start snapshot root at:\n\t%s\n' "$snapshotRoot"

declare -r pidFile="${snapshotRoot}/rsyncrotate-${sshPrint}.pid"
isSyncRunning() (
  [ -e "$pidFile" ] || return 1

  [ -f "$pidFile" ] ||
    die 'Found non-regular file where PID file should be:\n\t%s\n' "$pidFile"

  local pid
  pid="$(cat "$pidFile" || die 'Failed to open PID file:\n\t%s\n' "$pidFile")"
  [ -n "${pid/ */}" ] || return 1

  kill -0 "$pid" >/dev/null 2>&1
)

if isSyncRunning;then
  die "Sync already in progress (PID=%s) for ssh key, '%s'\n" \
    "$(< "$pidFile")" "$sshPrint"
else
  echo -n "$$" > "$pidFile"
  isPidFileOurs=1
fi

if isPush;then
  log 'Interpreting this as a PUSH, appending $interval, "%s"\n' \
    "$lowInterval"
  declare -r destPath="${snapshotRoot}/${lowInterval}.0"/
else
  log 'Interpretting this as a PULL, not appending $interval\n'
  declare -r destPath="$snapshotRoot"
fi

declare -r conf="$tmpfsDir"/rsnapshot-"$requestId".conf
isWriteableDir "$(dirname "$conf")" ||
  die 'expected tempfs directory not found:\n\t%s\n' "$(dirname "$conf")"

cp "$baseConf" "$conf" ||
  die 'failed getting base conf from\n\t%s\nto:\t%s\n' "$baseConf" "$conf"
sed -i "s|BACKER_MNT_PATH/|$snapshotRoot|g" "$conf" ||
  die 'failed editing custom config:\t%s\n' "$conf"

#############################################################
# Setup complete; move on to actually backup ################
if isPush;then
  log 'Rotating snapshots, before receivng PUSH...\n'
  if [ -d "$destPath" ];then
    declare -r intervBase="${snapshotRoot}/${lowInterval}."
    tmpCopy="$(
      mktemp --directory \
        --tmpdir="$snapshotRoot" "${lowInterval}.base_XXXXXX.d" ||
          die 'Failed to mktemp directory to save base copy before rotation\n'
    )"; declare -r tmpCopy
    cp --link --archive ${intervBase}0/. "$tmpCopy" ||
      die 'Failed to duplicate base copy before rotation\n'

    rsnapshot -c "$conf" "$lowInterval" ||
      die 'Failed rotating snapshot interval, "%s"\n' "$lowInterval"

    mv "$tmpCopy" ${intervBase}0 || die \
       'Failed to recover saved basecopy after rotation\n\ttmp: "%s"\n\t%s\n' \
       "$tmpCopy" ${intervBase}0
    # TODO have someone w/more knowledge of rsnapshot look at this ^ this must
    # be unnecessary - perhaps there's some order to call rsnapshot in that
    # *it* will do the sync for me (eg: with sync_first? - but without the
    # borked `path`?)
  else
    wrn 'First backup? Lowest interval, "%s" not present; creating now...\n' \
      "$lowInterval"
    mkdir "$destPath" ||
      die 'Failed to start first interval:\n\t%s\n' "$destPath"
  fi
fi

log \
  'Running rrsync over $SSH_ORIGINAL_COMMAND:\n\t"%s"\n' \
  "$SSH_ORIGINAL_COMMAND"
"$rrsyncExec" "$destPath" ||
  die 'rrsync FAILED using restricted directory:\n\t"%s"\n' "$destPath"

log 'DONE. %sSync SUCCEEDED\n' "$(
  if isPush;then printf 'Rotate & ';fi
)"
cleanupTemps >/dev/null 2>&1
