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
  local dependencies=""
  [[ -z "${3:-}" ]] || dependencies="\"$3\""
  mkdir -p "$(dirname "$1")"
  cat >"$1" <<EOF
# /// script
# requires-python = "${2:->=3.10}"
# dependencies = [$dependencies]
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

@test "keeps an up-to-date lock file of an outdated dependency, without network" {
  write_script foo.py ">=3.10" "idna"
  cat >foo.py.lock <<'EOF'
version = 1
revision = 5
requires-python = ">=3.10"

[manifest]
requirements = [{ name = "idna" }]

[[package]]
name = "idna"
version = "3.7"
source = { registry = "https://pypi.org/simple" }
sdist = { url = "https://files.pythonhosted.org/packages/21/ed/f86a79a07470cb07819390452f178b3bef1d375f2ec021ecfc709fc7cf07/idna-3.7.tar.gz", hash = "sha256:028ff3aadf0609c1fd278d8ea3089299412a7a8b9bd005dd08b9f8285bcb5cfc", size = 189575, upload-time = "2024-04-11T03:34:43.276Z" }
wheels = [
    { url = "https://files.pythonhosted.org/packages/e5/3e/741d8c82801c347547f8a2a06aa57dbb1992be9e948df2ea0eda2c8b79e8/idna-3.7-py3-none-any.whl", hash = "sha256:82fee1fc78add43492d3a1898bfa6d8a904cc97d8427f683ed8e798d07761aa0", size = 66836, upload-time = "2024-04-11T03:34:41.447Z" },
]
EOF
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
