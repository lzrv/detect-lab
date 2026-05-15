# uv Scan Target: astral-sh/uv

**Repo:** https://github.com/astral-sh/uv
**Cloned to:** /opt/scan_targets/uv/uv

## Why this project

The uv project (the package manager itself) manages its Python tooling with uv and has a
committed `uv.lock` at the repo root, making it the natural target for the UV Lock detector.

## Pre-scan steps

No setup required. `uv.lock` is committed and parsed directly by the UV Lock detector.
For CLI detection (uv must resolve the environment):

```
cd /opt/scan_targets/uv/uv
uv sync --frozen
```

## Recommended scan.sh invocation

```
scan.sh --uv
```

Detect project name: `uv-detect-11.4.2-test`
Detectors: UV Lock, UV CLI
Search depth: 2 (default)
