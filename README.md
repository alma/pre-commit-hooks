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
      args: ["README.md:3698169c579b63d33883fb2dce10e1199c849958"]
```

### Hooks available

#### `check-file-change

Make sure files didn't change.
You must provide list of target files with their expected checksum in a given algorithm. (Default is sha1)
You can change the algorithm with the ``--algorithm=sha256`` option.
