# Alma pre-commit hooks

Shared [pre-commit](https://pre-commit.com) hooks for Alma repositories. They work with both
[prek](https://prek.j178.dev) and pre-commit.

## Usage

Add the hooks you need to your `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/alma/pre-commit-hooks
    rev: v2.0.0 # pin a full version, see below
    hooks:
      - id: check-branch-name
        args: ["-r^((feature|fix)/.*|main)$"]
```

Always pin a full `vX.Y.Z` version, never a branch. pre-commit caches each `rev` forever, so a moving
reference would never be updated on your machine. To get a PR when a new version is released, enable
Renovate's [pre-commit manager](https://docs.renovatebot.com/modules/manager/pre-commit/). See the
[releases](https://github.com/alma/pre-commit-hooks/releases) for what changed.

## Hooks

| Hook                                      | Description                                    |
|-------------------------------------------|------------------------------------------------|
| [`check-branch-name`](#check-branch-name) | Checks the current branch name against a regex |

### check-branch-name

Fails when the name of the current branch doesn't match a regex. It runs once per commit, without file
names, and is skipped when the commit stages no file.

| Argument    | Required | Description                                               |
|-------------|----------|-----------------------------------------------------------|
| `-r<regex>` | yes      | Branch names must match this bash regex                   |
| `-e<regex>` | no       | Branches matching this bash regex are skipped (e.g. bots) |

```yaml
      - id: check-branch-name
        args:
          - "-r^((ci|docs|feature|fix|hotfix|perf|refactor|test)/.*|main)$"
          - "-e^renovate/"
```

## Upgrading from 1.x

`check-branch-name` is unchanged in 2.0.0: only bump the `rev`. The `check-file-change` and
`check-comments` hooks were removed.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
