# Poetry Scan Target: python-poetry/poetry

**Repo:** https://github.com/python-poetry/poetry
**Cloned to:** /opt/scan_targets/poetry/poetry

## Why this project

Poetry is itself the canonical Poetry-managed project: it has both `pyproject.toml` and a
committed `poetry.lock` at the repo root. This makes it the ideal target for the Poetry Lock
detector. Its dependency tree is moderately sized with well-known packages.

## Pre-scan steps

No setup required. The `poetry.lock` file is committed and Detect will parse it directly.
Poetry installation is not necessary for lock-file-based detection.

For CLI-based detection (optional):

```
cd /opt/scan_targets/poetry/poetry
poetry install --no-root
```

## Recommended scan.sh invocation

```
scan.sh --poetry
```

Detect project name: `poetry-detect-11.4.2-test`
Detectors: Poetry Lock
Search depth: 2 (default)
