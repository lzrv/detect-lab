# Pipenv Scan Target: pypa/pipenv

**Repo:** https://github.com/pypa/pipenv
**Cloned to:** /opt/scan_targets/pipenv/pipenv

## Why this project

Pipenv is the reference implementation for `Pipfile`/`Pipfile.lock` based workflows. The
repo carries a committed `Pipfile.lock` at the root, which is precisely what the Pipfile Lock
and Pipenv CLI detectors look for. Using the tool itself as the scan target ensures
correctness.

## Pre-scan steps

No setup required. `Pipfile.lock` is committed and will be parsed directly. For CLI-based
detection:

```
cd /opt/scan_targets/pipenv/pipenv
pipenv install --deploy --ignore-pipfile
```

## Recommended scan.sh invocation

```
scan.sh --pipenv
```

Detect project name: `pipenv-detect-11.4.2-test`
Detectors: Pipfile Lock, Pipenv CLI
Search depth: 2 (default)
