# Bazel Scan Target: abseil/abseil-cpp

**Repo:** https://github.com/abseil/abseil-cpp
**Cloned to:** /opt/scan_targets/bazel/abseil-cpp

## Why this project

abseil-cpp is Google's Abseil C++ library, built with Bazel. It has a `BUILD.bazel` /
`WORKSPACE` structure at the root that the Bazel CLI detector can query via
`bazel query //...`. The project has external dependency declarations in the `WORKSPACE`
file, which Detect uses to build the dependency graph. Bazel binary is installed at
`/usr/local/bin/bazel`.

## Pre-scan steps

Bazel downloads the JDK and build toolchain on first invocation (internet access required).
To pre-warm the Bazel output base:

```
cd /opt/scan_targets/bazel/abseil-cpp
bazel fetch //... 2>/dev/null || true
```

Note: The first `bazel` call may take several minutes while it bootstraps.

## Recommended scan.sh invocation

```
scan.sh --bazel
```

Detect project name: `bazel-detect-11.4.2-test`
Detectors: Bazel CLI
Search depth: 2 (default)
