#!/usr/bin/env bash
set -euo pipefail

# Lock PEP 723 scripts: (re)generate <script>.py.lock for each script with inline metadata.
# Fails when a lock file isn't tracked by git, since pre-commit/prek only detect changes to tracked files.

EXIT_CODE=0
while IFS= read -r script; do
  uv lock --quiet --script "$script" || { EXIT_CODE=1; continue; }
  if ! git ls-files --error-unmatch -- "$script.lock" >/dev/null 2>&1; then
    echo "Lock file not tracked by git, add it: $script.lock"
    EXIT_CODE=1
  fi
done < <(grep -l -- '^# /// script$' "$@" || true)
exit "$EXIT_CODE"
