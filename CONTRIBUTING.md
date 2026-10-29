# Contributing

## Repository layout

```
.pre-commit-hooks.yaml   # the hook definitions consumers reference
hooks/<hook-id>.sh       # one script per hook, named after its id
tests/<hook-id>.bats     # the hook's tests
README.md                # a section per hook
```

## Adding a hook

1. Write `hooks/<hook-id>.sh`, executable (`chmod +x`), with a shebang. Hooks use `language: script`, so
   any tool they need (e.g. `uv`) must be on the consumer's `PATH`: document it in the README.
2. Declare it in `.pre-commit-hooks.yaml` with `entry: hooks/<hook-id>.sh`.
3. Add `tests/<hook-id>.bats`, written with [bats](https://bats-core.readthedocs.io). The tests call the
   script directly with the arguments and file names pre-commit would pass, and check its exit status and
   output. See `tests/uv-lock-script.bats`.
4. Add a section to `README.md`: what it does, its arguments, its requirements, an example.

## Testing locally

Install [mise](https://mise.jdx.dev), then the tools CI uses, at the versions of `mise.toml`:

```bash
mise install                  # prek, bats and uv
prek run --all-files          # lint: shellcheck, zizmor, manifest validation
bats tests/                   # all tests, as CI runs them
bats tests/<hook-id>.bats     # one hook's tests
```

To change a tool's version, run `mise use <tool>@<version>`: it updates `mise.toml` and `mise.lock`.

To try a hook in another repository before it's released, run from that repository:

```bash
prek try-repo /path/to/pre-commit-hooks <hook-id> --all-files
```

CI runs the same commands on every PR. On a PR from a fork, GitHub may wait for a maintainer to approve the
workflow runs before CI starts.

## Releasing

**Every merge to `main` publishes a release**: a `vX.Y.Z` tag and a GitHub release whose notes list the
merged PR titles, so write the title for consumers.

The bump is chosen by the label of the merged PR. A PR can't be merged until the "Release label" check
passes, and it only passes when the PR has **exactly one** of these labels:

| Label           | Bump       | When                                                    |
|-----------------|------------|---------------------------------------------------------|
| `release:major` | major      | Breaking change, see below                              |
| `release:minor` | minor      | A new hook, a new option, a change in behavior          |
| `release:patch` | patch      | Bug fix with no change in behavior                      |
| `norelease`     | no release | Nothing consumers can see: docs, CI, tests, tooling     |

Only people with write access to the repository can add labels. If you contribute from a fork, say in the PR
description which label you think fits: a maintainer adds it during the review, and the check stays red until
then. Renovate PRs get `norelease` automatically (`.github/renovate.json5`): they only update CI and dev tooling.

A change is **breaking** when a consumer bumping `rev` can be broken without changing their config:

- removing or renaming a hook id;
- removing or renaming an argument, or making a new one required;
- requiring a new tool on the consumer's machine;
- making the hook fail where it used to pass (e.g. a stricter check).

Moving or renaming a hook's script is **not** breaking: consumers only reference the hook id, and
pre-commit resolves `entry` at the pinned version.

Rules for tags:

- Never delete, move or re-create a tag. Consumers pin them, and pre-commit caches each `rev` forever.
- There is no floating major tag (`v2`), for the same reason.
