# Erlang Scan Target: ninenines/cowboy

**Repo:** https://github.com/ninenines/cowboy
**Cloned to:** /opt/scan_targets/erlang/cowboy

## Why this project

Cowboy is a well-known Erlang HTTP server with a `rebar.config` and committed `rebar.lock`
at the repo root. This exercises both the Erlang Rebar CLI detector (runs `rebar3 deps`)
and the Rebar lock file parser. Erlang/OTP and rebar3 are both installed in the container.

## Pre-scan steps

No setup required for lock-file detection. For the rebar3 CLI detector:

```
cd /opt/scan_targets/erlang/cowboy
rebar3 get-deps
```

This fetches all Hex dependencies into the `_build/` tree so Detect can resolve the graph.

## Recommended scan.sh invocation

```
scan.sh --erlang
```

Detect project name: `erlang-detect-11.4.2-test`
Detectors: Erlang Rebar CLI
Search depth: 2 (default)
