# uv Scan Target: astral-sh/ruff

**Repo:** https://github.com/astral-sh/ruff
**Cloned to:** /opt/scan_targets/uv/ruff

## Why this project

Ruff is a Rust-based Python linter maintained by Astral (the same team behind uv). It uses
uv for dependency management and has a committed `uv.lock` at the repo root, making it the
natural target for the UV Lock and UV CLI detectors.

## Pre-scan steps

No setup required. `uv.lock` is committed and parsed directly by the UV Lock detector.
For CLI detection (uv must resolve the environment):

```
cd /opt/scan_targets/uv/ruff
uv sync --frozen
```

## Recommended scan.sh invocation

```
scan.sh --uv
```

Detect project name: `uv-detect-11.4.2-test`
Detectors: UV Lock, UV CLI
Search depth: 2 (default)
