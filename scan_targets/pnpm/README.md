# pnpm Scan Target: vitejs/vite

**Repo:** https://github.com/vitejs/vite
**Cloned to:** /opt/scan_targets/pnpm/vite

## Why this project

Vite is a high-profile frontend build tool that uses pnpm as its package manager. It has a
committed `pnpm-lock.yaml` at the repo root, which is exactly what the Pnpm Lock detector
requires. The monorepo layout (multiple `package.json` files) also exercises detector search
depth.

## Pre-scan steps

No setup required. The `pnpm-lock.yaml` is committed. To also exercise the pnpm CLI detector,
install dependencies first:

```
cd /opt/scan_targets/pnpm/vite
pnpm install --frozen-lockfile
```

## Recommended scan.sh invocation

```
scan.sh --pnpm
```

Detect project name: `pnpm-detect-11.4.2-test`
Detectors: Pnpm Lock, pnpm CLI
Search depth: 2 (default)
