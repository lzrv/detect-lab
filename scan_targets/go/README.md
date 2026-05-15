# Go Scan Target: cli/cli

**Repo:** https://github.com/cli/cli
**Cloned to:** /opt/scan_targets/go/cli

## Why this project

`gh` (GitHub CLI) is a large, well-maintained Go module with a committed `go.mod` and
`go.sum` at the repo root. It has a substantial dependency tree including widely-used
packages, making it a realistic test for both the Go Mod File detector (parses `go.mod`
directly) and the GoMod CLI detector (runs `go mod graph`).

## Pre-scan steps

No setup required. The Go Mod File detector parses `go.mod` and `go.sum` without building.
For the GoMod CLI detector, Go must be able to download the module graph:

```
cd /opt/scan_targets/go/cli
go mod download
```

## Recommended scan.sh invocation

```
scan.sh --go
```

Detect project name: `go-detect-11.4.2-test`
Detectors: GoMod CLI, Go Mod File
Search depth: 2 (default)
