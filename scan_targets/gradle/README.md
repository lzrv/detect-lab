# Gradle Scan Target: square/okhttp

**Repo:** https://github.com/square/okhttp
**Cloned to:** /opt/scan_targets/gradle/okhttp

## Why this project

OkHttp is Square's HTTP client for the JVM, built with Gradle. Its multi-module build
structure (several subprojects under `okhttp-*/`) exercises the Gradle Native Inspector's
ability to resolve dependencies across modules. The project uses Gradle wrapper (`gradlew`),
which Detect invokes automatically.

## Pre-scan steps

No setup required. Detect invokes `./gradlew dependencies` via the Gradle Native Inspector.
Gradle will download dependencies on first run (internet access required, or pre-warm):

```
cd /opt/scan_targets/gradle/okhttp
./gradlew dependencies --quiet 2>/dev/null || true
```

## Recommended scan.sh invocation

```
scan.sh --gradle
```

Detect project name: `gradle-detect-11.4.2-test`
Detectors: Gradle Native Inspector
Search depth: 2 (default)
