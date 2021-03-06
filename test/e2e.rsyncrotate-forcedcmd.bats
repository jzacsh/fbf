#!/usr/bin/env bats

targetSh="$SRC_DIR"/rsyncrotate-forcedcmd.sh; declare -r targetSh
fakeSshFprint=63e5ae042d29b7104dff26d13c546e12; declare -r fakeSshFprint

# re-apply simple `vagrant status` grep once resolution one:
# https://github.com/sstephenson/bats/issues/175
#
# {
#   vagrant status | grep -E 'default[[:space:]]*running' >/dev/null 2>&1 || {
#     echo 'Have you run `vagrant up`?' >&2
#     exit 1
#   }
# } &

# TODO fail if < bashv4

rsync() (
  vagrant ssh-config > "$TMPDIR"/ssh.config
  rsync -e "ssh -F "$TMPDIR"/ssh.config" $@
)

stampLess() (
  local row="${1:-0}"; local ln="${lines[$row]}";
  echo "${ln/*][[:space:]]/}"
)

@test 'should refuse to run without ssh-fprint' {
  run "$targetSh"
  [ "$status" -ne 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "$(stampLess)" = 'ERROR: Usage: Expected SSH finger print and backup config path' ]
}

@test 'should refuse to run with whitespace ssh-fprint' {
  run "$targetSh" "$(printf ' \t ')"
  [ "$status" -ne 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "$(stampLess)" = 'ERROR: Usage: Expected SSH finger print and backup config path' ]
}

@test 'should insist on non-empty config file argument' {
  run "$targetSh" "$fakeSshFprint"
  [ "$status" -ne 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "$(stampLess)" = 'ERROR: Usage: Expected SSH finger print and backup config path' ]

  someWhiteSpace="$(printf ' \t ')"
  run "$targetSh" "$fakeSshFprint" "$someWhiteSpace"
  [ "$status" -ne 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "$(stampLess 0)" = 'ERROR: Backup config path is not a readable file:' ]
  [ "${lines[1]}" = "$(printf '\t"%s"' "$someWhiteSpace")" ]
}

@test 'should insist on regular config file' {
  run "$targetSh" "$fakeSshFprint" /dev/null
  [ "$status" -ne 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "$(stampLess 0)" = 'ERROR: Backup config path is not a readable file:' ]
  [ "${lines[1]}" = "$(printf '\t"/dev/null"')" ]
}

@test 'should insist on readable config file' {
  unreadableConf="$TMPDIR"/notreadable
  echo boop > "$unreadableConf"
  chmod u-r "$unreadableConf"
  ! [ "$unreadableConf" ]

  run "$targetSh" "$fakeSshFprint" "$unreadableConf"
  [ "$status" -ne 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "$(stampLess 0)" = 'ERROR: Backup config path is not a readable file:' ]
  [ "${lines[1]}" = "$(printf '\t"%s"' "$unreadableConf")" ]
}

@test 'should die if empty $SSH_ORIGINAL_COMMAND' {
  echo boop > "$TMPDIR"/testBackupConf
  [ -z "${SSH_ORIGINAL_COMMAND/ *}" ]
  run "$targetSh" "$fakeSshFprint" "$TMPDIR"/testBackupConf
  [ "$status" -ne 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "$(stampLess)" = 'ERROR: Login not allowed; found empty $SSH_ORIGINAL_COMMAND' ]
}

@test 'should die if $SSH_ORIGINAL_COMMAND not rsync --server' {
  echo boop > "$TMPDIR"/testBackupConf
  SSH_ORIGINAL_COMMAND=hackyouservers \
    run "$targetSh" "$fakeSshFprint" "$TMPDIR"/testBackupConf
  [ "$status" -ne 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "$(stampLess)" = 'ERROR: Only rsync to --server is allowed' ]
}

@test 'should require conf providing TARGET_PARENT' { skip; }
@test 'should require conf providing TMPFS_DIR' { skip; }
@test 'should require conf providing BASE_CONF' { skip; }
@test 'should require conf providing RRSYNC_EXEC' { skip; }

@test 'should require TMPFS_DIR is writeable directory' { skip; }

@test 'should fail w/o scraping non-empty lowest interval in rsnapshot.conf' { skip; }
@test 'should require successful cp of rsnapshot.conf' { skip; }
@test 'should require successful sed of rsnapshot conf' { skip; }

@test 'should not rotate snapshots when pulling' { skip; }
@test 'should not rotate snapshots when listing' { skip; }

# TODO write tests for `if isPush` block of logic

@test 'should require successful rsync' { skip; }

# TODO write tests for various/complicated cleanup logic
