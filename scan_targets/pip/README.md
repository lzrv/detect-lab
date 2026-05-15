# pip Scan Target: psf/requests

**Repo:** https://github.com/psf/requests
**Cloned to:** /opt/scan_targets/pip/requests

## Why this project

Requests is the most-downloaded Python package and uses a standard `setup.py` / `pyproject.toml`
with `requirements.txt`. It is intentionally simple — no build system tricks — making it the
cleanest target for the PIP CLI and Setuptools detectors. Every dependency is pip-installable
without OS-level prerequisites.

## Pre-scan steps

No setup required for Setuptools (parses `setup.py` directly). For the PIP CLI detector to
produce a full graph, install the project:

```
cd /opt/scan_targets/pip/requests
pip3 install -e . --quiet
```

## Recommended scan.sh invocation

```
scan.sh --pip
```

Detect project name: `pip-detect-11.4.2-test`
Detectors: PIP CLI, Setuptools
Search depth: 2 (default)
