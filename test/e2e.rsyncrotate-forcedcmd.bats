#!/usr/bin/env bats

setup() (
  vagrant status | grep -E 'default[[:space:]]*running' >/dev/null 2>&1 ||
    echo 'Have you run `vagrant up`?' >&2
)

rsync() (
  vagrant ssh-config > "$TMPDIR"/ssh.config
  rsync -e "ssh -F "$TMPDIR"/ssh.config" $@
)

@test 'should refuse to run without ssh-fprint' { skip; }
@test 'should refuse to run with whitespace ssh-fprint' { skip; }

@test 'should insist on non-emptyl config file argument' { skip; }
@test 'should insist on regular config file' { skip; }
@test 'should insist on readable config file' { skip; }

@test 'should die if empty $SSH_ORIGINAL_COMMAND' { skip; }
@test 'should die if $SSH_ORIGINAL_COMMAND not rsync --server' { skip; }

@test 'should require conf providing TARGET_PARENT' { skip; }
@test 'should require conf providing TMPFS_DIR' { skip; }
@test 'should require conf providing BASE_CONF' { skip; }
@test 'should require conf providing RRSYNC_EXEC' { skip; }

@test 'should require TMPFS_DIR is writeable directory' { skip; }

@test 'should fail w/o scraping non-empty lowest interval in rsnapshot.conf' { skip; }
@test 'should require successful cp of rsnapshot.conf' { skip; }
@test 'should require successful sed of rsnapshot conf' { skip; }

@test 'should not rotate snapshots when pulling' { skip; }
@test 'should not rotate snapshots when listin' { skip; }

# TODO write tests for `if isPush` block of logic

@test 'should require successful rsync' { skip; }

# TODO write tests for various/complicated cleanup logic
