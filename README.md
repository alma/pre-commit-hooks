Alma pre-commit-hooks
=====================

Some Alma hooks for pre-commit.

See also: https://github.com/pre-commit/pre-commit


## Using pre-commit-hooks with pre-commit

Add this to your `.pre-commit-config.yaml`.
Only use the sections of the checks you want to use (each section starts with `- id: a-check-name`.

```yaml
-   repo: https://github.com/alma/pre-commit-hooks
    rev: 1.0.0
    hooks:
    - id: check-file-change
      files: "^config.*.yaml$"
      args:
        - --check
        - config.dev.yaml:eacaec4b8c4665dfce2d0e082acd0d39787457da
        - config.prod.yaml:eacaec4b8c4665dfce2d0e082acd0d39787457da
        - --
    - id: check-comments
```

## Hooks available

The hooks below are available in this repository.

### check-file-change

Make sure files didn't change.
You must provide list of target files with their expected checksum in a given algorithm. (Default is sha1)
You can change the algorithm with the ``--algorithm=sha256`` option.

### check-comment

Checks that the modified files contain at least one line of comment.

#### Dependencies

This hook relies on (should be installed on the local machine / VM):
* [cloc](https://github.com/AlDanial/cloc)
* [jq](https://stedolan.github.io/jq/)
