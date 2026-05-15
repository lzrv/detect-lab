# Conan Scan Target: conan-io/examples

**Repo:** https://github.com/conan-io/examples
**Cloned to:** /opt/scan_targets/conan/examples

## Why this project

The official Conan examples repository contains multiple subprojects, each with
`conanfile.txt` or `conanfile.py` manifests. It covers both Conan 1.x and Conan 2.x style
projects, exercising the Conan 1 CLI, Conan 2 CLI, and Conan Lock detectors. Conan is
installed via pip3 in the container.

## Pre-scan steps

For CLI-based detection, Conan must install the dependencies for a specific example. Point
Detect at a subproject with a lockfile, or generate one:

```
cd /opt/scan_targets/conan/examples/examples/libraries/conan-center/bzip2
conan install . --output-folder=build --build=missing
```

For lock-file detection (Conan Lock detector), generate a lockfile:

```
conan lock create conanfile.txt -s os=Linux
```

For simpler file-parse detection, Detect will scan `conanfile.txt` directly without CLI.

## Recommended scan.sh invocation

```
scan.sh --conan
```

Detect project name: `conan-detect-11.4.2-test`
Detectors: Conan 1 CLI, Conan 2 CLI, Conan Lock
Search depth: 2 (default)
