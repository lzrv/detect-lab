# Cargo Scan Target: sharkdp/bat

**Repo:** https://github.com/sharkdp/bat
**Cloned to:** /opt/scan_targets/cargo/bat

## Why this project

`bat` is a popular Rust CLI tool (a `cat` replacement with syntax highlighting). It has a
committed `Cargo.lock` at the repo root and a clean `Cargo.toml` dependency structure. The
Cargo Lock detector parses the lockfile directly; the Cargo CLI detector runs `cargo metadata`.
Rust + cargo are installed via rustup in the container.

## Pre-scan steps

No setup required for lock-file detection. For Cargo CLI detection, cargo downloads and
caches registry metadata on first run:

```
cd /opt/scan_targets/cargo/bat
cargo fetch --quiet
```

## Recommended scan.sh invocation

```
scan.sh --cargo
```

Detect project name: `cargo-detect-11.4.2-test`
Detectors: Cargo Lock, Cargo CLI
Search depth: 2 (default)
