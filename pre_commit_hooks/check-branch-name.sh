#!/bin/bash

while getopts r:e: flag
do
    case "${flag}" in
        r) BRANCH_NAME_REGEX=${OPTARG};;
        e) EXCLUDE_BRANCH_REGEX=${OPTARG};;
        *) echo "Invalid flag provided ($flag)"; exit 1;
    esac
done

if [[ $BRANCH_NAME_REGEX == "" ]]; then
  echo "No regular expression provided to validate the branch name..."
  echo "Please provide one using the '-r' argument."
  echo ""
  echo "Sample 'repo' section of your '.pre-commit-config.yaml' file:"
  echo "- repo: https://github.com/alma/pre-commit-hooks"
  echo "  rev: v1.1.0"
  echo "  hooks:"
  echo "  - id: check-branch-name"
  echo "    args:"
  echo '      - "-r^(((ci|docs|feature|fix|hotfix|perf|refactor|test)\/.*)|main)$"'
  exit 1
fi

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

if [[ -n $EXCLUDE_BRANCH_REGEX && $BRANCH_NAME =~ $EXCLUDE_BRANCH_REGEX ]]; then
  exit 0
fi

if ! [[ $BRANCH_NAME =~ $BRANCH_NAME_REGEX ]]; then
    echo "*** Commit interrupted ***"
    echo "Your branch name does not match the naming convention."
    echo "Branch names should match \"$BRANCH_NAME_REGEX\"."
    echo "Your branch is named \"$BRANCH_NAME\"..."

    exit 1
fi
