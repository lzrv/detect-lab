# SBT Scan Target: scala/scala-parser-combinators

**Repo:** https://github.com/scala/scala-parser-combinators
**Cloned to:** /opt/scan_targets/sbt/scala-parser-combinators

## Why this project

scala-parser-combinators is a small, official Scala library maintained by the Scala team.
Its `build.sbt` has a clear, compact dependency set making it easy to verify detection
results. SBT is installed in the container at `/usr/local/bin/sbt`, satisfying the Sbt
Native Inspector's requirement.

## Pre-scan steps

On first run SBT will bootstrap itself and download Scala + dependencies (internet access
required). To pre-warm:

```
cd /opt/scan_targets/sbt/scala-parser-combinators
sbt update
```

This downloads all dependencies into the Ivy cache so subsequent scans are faster.

## Recommended scan.sh invocation

```
scan.sh --sbt
```

Detect project name: `sbt-detect-11.4.2-test`
Detectors: Sbt Native Inspector
Search depth: 2 (default)
