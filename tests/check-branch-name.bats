#!/usr/bin/env bats

bats_require_minimum_version 1.5.0 # run --separate-stderr

setup() {
  HOOK="$BATS_TEST_DIRNAME/../hooks/check-branch-name.sh"
  # Isolate from the developer's git config (commit signing, global hooks, ...) and from an outer repository
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
  unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE
  cd "$BATS_TEST_TMPDIR" || return 1
  git init --quiet --initial-branch=main
  git -c user.name=test -c user.email=test@example.com commit --quiet --allow-empty -m init
}

REGEX='^((feature|fix)/.*|main)$'

@test "fails without a regex" {
  run "$HOOK"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No regular expression provided"* ]]
}

@test "prints a deprecation notice on stderr" {
  run --separate-stderr "$HOOK" -r "$REGEX"
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"check-branch-name is deprecated"* ]]
  [[ "$output" != *"deprecated"* ]]
}

@test "prints the deprecation notice when it fails too" {
  git checkout --quiet -b wip
  run --separate-stderr "$HOOK" -r "$REGEX"
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"check-branch-name is deprecated"* ]]
}

@test "passes on a matching branch" {
  git checkout --quiet -b feature/foo
  run "$HOOK" -r "$REGEX"
  [ "$status" -eq 0 ]
}

@test "passes on main" {
  run "$HOOK" -r "$REGEX"
  [ "$status" -eq 0 ]
}

@test "fails on a non-matching branch" {
  git checkout --quiet -b wip
  run "$HOOK" -r "$REGEX"
  [ "$status" -eq 1 ]
  [[ "$output" == *'Your branch is named "wip"'* ]]
}

@test "passes on a non-matching but excluded branch" {
  git checkout --quiet -b renovate/foo
  run "$HOOK" -r "$REGEX" -e '^renovate/'
  [ "$status" -eq 0 ]
}

@test "fails on an invalid flag" {
  run "$HOOK" -x foo
  [ "$status" -eq 1 ]
}
