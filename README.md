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
      - id: uv-lock-script
```

Always pin a full `vX.Y.Z` version, never a branch. pre-commit caches each `rev` forever, so a moving
reference would never be updated on your machine. To get a PR when a new version is released, enable
Renovate's [pre-commit manager](https://docs.renovatebot.com/modules/manager/pre-commit/). See the
[releases](https://github.com/alma/pre-commit-hooks/releases) for what changed.

## Hooks

| Hook                                | Description                                        |
|-------------------------------------|----------------------------------------------------|
| [`uv-lock-script`](#uv-lock-script) | Keeps the lock files of PEP 723 scripts up to date |

### uv-lock-script

Keeps the `<script>.py.lock` lock file of every Python script with [PEP 723](https://peps.python.org/pep-0723/)
inline metadata up to date, with `uv lock --script`:

- a stale lock file is rewritten, and the hook fails so you can stage it;
- a missing lock file is created, and the hook fails so you can add it.

Requires [uv](https://docs.astral.sh/uv/) on your `PATH`.

```yaml
      - id: uv-lock-script
        files: ^scripts/.*\.py(\.lock)?$ # optional, defaults to every Python file
```

Run the scripts with `uv run --locked --script <script>.py`, so a stale lock file fails instead of being
silently rewritten.

## Upgrading from 1.x

All the 1.x hooks were removed:

- `check-branch-name`: use a GitHub ruleset with a [**Restrict branch names**][restrict-branch-names] rule
  instead. It's enforced at push, so it can't be skipped locally. In Alma repositories, ask DevX to add the
  repository to the organization ruleset.
- `check-file-change` and `check-comments`: no replacement.

[restrict-branch-names]: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository#adding-metadata-restrictions

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
