#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DEBUG=${DEBUG:=0}
[[ "$DEBUG" = "1" ]] && set -o xtrace

if ! command which cloc &>/dev/null; then
  >&2 echo 'cloc command not found, please install it'
  exit 1
fi

if ! command which jq &>/dev/null; then
  >&2 echo 'jq command not found, please install it'
  exit 1
fi

has_errors=0

function check_file
{
    local file_path="$1"
    local stats=$(cloc --json "$file_path")
    if [ -z "$stats" ]
    then
        # no stats, empty file?
        return
    fi

    local lines_count=$(echo "$stats" | jq '.header.n_lines')
    if [ "$lines_count" -le 1 ]
    then
        # empty file
        return
    fi

    local comments_count=$(echo "$stats" | jq '.SUM.comment')
    if [ "$comments_count" -eq 0 ]
    then
        >&2 echo "File $@ contains 0 comments"
        has_errors=1
    fi

    # all good!
    return
}

for file_path in "$@"
do
    check_file "$file_path"
done
exit $has_errors
