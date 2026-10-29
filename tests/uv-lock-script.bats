#!/usr/bin/env bats

setup() {
  HOOK="$BATS_TEST_DIRNAME/../hooks/uv-lock-script.sh"
  cd "$BATS_TEST_TMPDIR" || return 1
  # Isolate git and uv from the developer's config, cache and outer repository.
  # Scripts without dependencies lock without the network.
  unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
  git init --quiet
  export UV_NO_CONFIG=1 UV_CACHE_DIR="$BATS_TEST_TMPDIR/uv-cache" UV_OFFLINE=1
}

# write_script <path> [requires-python] [dependency]: a PEP 723 script
write_script() {
  mkdir -p "$(dirname "$1")"
  cat >"$1" <<EOF
# /// script
# requires-python = "${2:->=3.10}"
# dependencies = [${3:+"$3"}]
# ///
print("hello")
EOF
}

@test "creates a missing lock file and fails" {
  write_script scripts/foo.py
  run "$HOOK" scripts/foo.py
  [ "$status" -eq 1 ]
  [[ "$output" == *"Lock file not tracked by git, add it: scripts/foo.py.lock"* ]]
  [ -f scripts/foo.py.lock ]
}

@test "fails while the lock file isn't added to git" {
  write_script foo.py
  uv lock --quiet --script foo.py
  run "$HOOK" foo.py
  [ "$status" -eq 1 ]
  git add foo.py.lock
  run "$HOOK" foo.py
  [ "$status" -eq 0 ]
}

@test "passes and keeps an up-to-date lock file unchanged" {
  write_script foo.py
  uv lock --quiet --script foo.py
  git add foo.py.lock
  cp foo.py.lock expected.lock
  run "$HOOK" foo.py
  [ "$status" -eq 0 ]
  cmp foo.py.lock expected.lock
}

@test "rewrites a stale lock file" {
  write_script foo.py ">=3.10"
  uv lock --quiet --script foo.py
  git add foo.py.lock
  write_script foo.py ">=3.11"
  run "$HOOK" foo.py
  # pre-commit fails the hook because the tracked lock file changed
  [ "$status" -eq 0 ]
  grep -q 'requires-python = ">=3.11"' foo.py.lock
}

@test "fails with uv's error when the script can't be locked" {
  write_script foo.py ">=3.10" "requests"
  run "$HOOK" foo.py
  [ "$status" -ne 0 ]
  [[ "$output" != *"add it"* ]]
  [ ! -f foo.py.lock ]
}

@test "still locks the other scripts when one can't be locked" {
  write_script broken.py ">=3.10" "requests"
  write_script foo.py
  run "$HOOK" broken.py foo.py
  [ "$status" -eq 1 ]
  [ -f foo.py.lock ]
}

@test "ignores Python files without inline metadata" {
  echo 'print("hello")' >plain.py
  run "$HOOK" plain.py
  [ "$status" -eq 0 ]
  [ ! -f plain.py.lock ]
}
