# Dart Scan Target: dart-lang/pub

**Repo:** https://github.com/dart-lang/pub
**Cloned to:** /opt/scan_targets/dart/pub

## Why this project

The `pub` package is the official Dart package manager tool. It has a `pubspec.yaml` and a
committed `pubspec.lock` at the repo root. This exercises both the Dart PubSpec Lock detector
(parses the lockfile directly) and the Dart CLI detector (runs `dart pub deps`). Dart SDK
is installed in the container at `/usr/lib/dart/bin/dart`.

## Pre-scan steps

No setup required for lockfile detection. The `pubspec.lock` is committed. For the Dart CLI
detector to produce a full dependency graph:

```
cd /opt/scan_targets/dart/pub
dart pub get --offline 2>/dev/null || dart pub get
```

## Recommended scan.sh invocation

```
scan.sh --dart
```

Detect project name: `dart-detect-11.4.2-test`
Detectors: Dart PubSpec Lock, Dart CLI
Search depth: 2 (default)
