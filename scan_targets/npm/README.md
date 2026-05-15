# NPM Scan Target: expressjs/express

**Repo:** https://github.com/expressjs/express
**Cloned to:** /opt/scan_targets/npm/express

## Why this project

Express is the canonical Node.js web framework with a committed `package-lock.json` (npm v2+
lockfile) at the repo root. It has a small, well-understood dependency tree, making it ideal
for exercising the NPM Package Lock and NPM CLI detectors reliably.

## Pre-scan steps

No setup required. The `package-lock.json` is committed, so Detect can run without executing
`npm install` first. If you want the CLI detector to resolve versions live, run:

```
cd /opt/scan_targets/npm/express
npm install --ignore-scripts
```

## Recommended scan.sh invocation

```
scan.sh --npm
```

Or with explicit credentials:

```
scan.sh --npm --url https://your-blackduck-host --token YOUR_TOKEN
```

Detect project name: `npm-detect-11.4.2-test`
Detectors: NPM Package Lock, NPM CLI
Search depth: 2 (default)
