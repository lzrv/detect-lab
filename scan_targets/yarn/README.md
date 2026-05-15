# Yarn Scan Target: facebook/jest

**Repo:** https://github.com/facebook/jest
**Cloned to:** /opt/scan_targets/yarn/jest

## Why this project

Jest is a large JavaScript testing framework maintained by Meta with a committed `yarn.lock`
at the repo root. Its monorepo layout (many packages under `packages/`) makes it a good
stress test for the Yarn Lock and Lerna CLI detectors. Lerna is also used for versioning,
so both detectors fire.

## Pre-scan steps

No setup required. The `yarn.lock` is committed and the Yarn Lock detector will parse it
without running `yarn install`. For CLI detection:

```
cd /opt/scan_targets/yarn/jest
yarn install --frozen-lockfile
```

## Recommended scan.sh invocation

```
scan.sh --yarn
```

Detect project name: `yarn-detect-11.4.2-test`
Detectors: Yarn Lock, Yarn CLI, Lerna CLI
Search depth: 2 (default)
