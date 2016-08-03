#!/usr/bin/env bats

provisionSh="$SRC_DIR"/provision-server.sh; declare -r provisionSh
fakeSshFprint=63e5ae042d29b7104dff26d13c546e12; declare -r fakeSshFprint


############################################################
# Tests for details in:
#   https://github.com/jzacsh/fbf/blob/0ca27559ad04/doc/labor.adoc#dedicated-hdd-host-given-dedicated-machine
#

@test 'rsync is installed' { skip; }
@test 'rsync service is running' { skip; }

@test 'creates custom rsnapshot conf' { skip; }
# TODO update this when log2rotate is used in rsnapshot's place
@test 'rsnapshot is installed' { skip; }
# TODO update this when log2rotate is used in rsnapshot's place

@test 'custom backup $USER added' { skip; }
@test 'backup $USER has home' { skip; }
@test 'backup $USER is marked "system"' { skip; }
@test 'proper tmpfs mount for backup $USER' { skip; }

@test 'properly mounted e2e testing drive $USER' { skip; }
# TODO update this ^ is temp config, while daemon is not yet written


############################################################
# Tests for details in:
#   https://github.com/jzacsh/fbf/blob/0ca27559ad04/doc/labor.adoc#rsyncsnapshotting-host-given-dedicated-hdd-host
#

@test 'installed current version/hash rsyncrotate-forcedcmd' { skip; }
@test 'installed latest rrsync' { skip; }
@test 'installed current version/hash default config ' { skip; }
