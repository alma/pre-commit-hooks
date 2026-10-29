# Benchmarks

Consumers run the hooks on `--all-files` in CI, so a hook must stay fast on large repositories. Benchmarks
aren't run in CI, since timings vary too much between runners: run them locally with
[hyperfine](https://github.com/sharkdp/hyperfine), from a repository using the hook:

```bash
hyperfine --warmup 1 --export-markdown bench.md "prek try-repo /path/to/pre-commit-hooks <hook-id> --all-files"
```

Paste the `bench.md` table in the hook's section below, with your setup.

## uv-lock-script

| Command | Mean Wall Time [ms] | Change | Factor |
|:---|---:|---:|:---|
| `prek try-repo pre-commit-hooks uv-lock-script --all-files` | 485.1 ± 35.2 |  |  |

Setup: a private monorepo with 7,043 Python files and 13 PEP 723 scripts, lock files up to date, offline
(`UV_OFFLINE=1`). Apple M5 (10 cores), macOS 27.2, prek 0.5.5, uv 0.12.23, hyperfine 2.0.0. 2026-10-29.
