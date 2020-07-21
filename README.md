Alma pre-commit-hooks
=====================

Some Alma hooks for pre-commit.

See also: https://github.com/pre-commit/pre-commit


### Using pre-commit-hooks with pre-commit

Add this to your `.pre-commit-config.yaml`

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
```

### Hooks available

#### `check-file-change

Make sure files didn't change.
You must provide list of target files with their expected checksum in a given algorithm. (Default is sha1)
You can change the algorithm with the ``--algorithm=sha256`` option.
