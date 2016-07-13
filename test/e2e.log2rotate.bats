#!/usr/bin/env bats

mockBackupList() (
  printf '%s\n' \
     2016-{05-{01..31},06-{01..30},07-{01..08}}T{00..23}:05 |
     sort --reverse;
)


target="$(readlink -f "$SRC_DIR"/log2rotate)"; declare -r target
setup() {
  [ -x "$target" ]

  # test our mock data, first, otherwise the below might have reason to change
  [ "$(mockBackupList | md5sum | cut -f 1 -d ' ')" = eaa285eb7550c1441efffaa447f4d3c8 ]
}

@test 'should provide help output' {
  run "$target" -h
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ 'usage: log2rotate' ]]

  run "$target" --help
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ 'usage: log2rotate' ]]
}

@test 'should should error without args' {
  run "$target"
  [ "$status" -ne 0 ]
  [[ "${lines[0]}" =~ 'USAGE ERROR: missing arguments to filter' ]]
}

@test 'should keep first and last' {
  run "$target" foo
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [[ "${lines[0]}" = 'foo' ]]

  run "$target" foo bar
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [[ "${lines[0]}" = 'foo' ]]
  [[ "${lines[1]}" = 'bar' ]]
}

@test 'should keep first and last' {
  run "$target" $(printf ' %s ' $(mockBackupList))
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 11 ]

  [ "${lines[ 0]}" = '2016-07-08T23:05' ] # spans from many recent...
  [ "${lines[ 1]}" = '2016-07-08T21:05' ]
  [ "${lines[ 2]}" = '2016-07-08T18:05' ]
  [ "${lines[ 3]}" = '2016-07-08T12:05' ]
  [ "${lines[ 4]}" = '2016-07-07T23:05' ]
  [ "${lines[ 5]}" = '2016-07-06T21:05' ]
  [ "${lines[ 6]}" = '2016-07-04T17:05' ]
  [ "${lines[ 7]}" = '2016-06-30T10:05' ]
  [ "${lines[ 8]}" = '2016-06-21T19:05' ]
  [ "${lines[ 9]}" = '2016-06-04T13:05' ]
  [ "${lines[10]}" = '2016-05-01T00:05' ] # snaps to only *fewer* older
}

@test 'should treat lines by order presented, not semantics of their content' {
  run "$target" $(printf ' %s ' $(mockBackupList | shuf))
  [ "$status" -eq 0 ]

  # output should not be semantically sorted
  ! diff -u \
    <(printf '%s\n' "${lines[@]}") \
    <(printf '%s\n' "${lines[@]}" | sort --reverse)
}
