# OCaml Scan Target: mirage/mirage

**Repo:** https://github.com/mirage/mirage
**Cloned to:** /opt/scan_targets/ocaml/mirage

## Why this project

MirageOS is the reference OCaml unikernel framework. It uses opam for package management
and has a committed `.opam` file (or `opam` file) at the repo root. This exercises the
OCaml Opam CLI detector (runs `opam list`) and the OCaml Opam Lock detector. OCaml + opam
are installed in the container; `opam init` has been run.

## Pre-scan steps

Opam requires a switch (compiler environment) to list installed packages. Initialize a
local switch for the scan:

```
cd /opt/scan_targets/ocaml/mirage
opam switch create . --deps-only --yes 2>/dev/null || true
eval $(opam env)
opam install . --deps-only --yes
```

This installs all declared dependencies so `opam list` returns a meaningful result.

## Recommended scan.sh invocation

```
scan.sh --ocaml
```

Detect project name: `ocaml-detect-11.4.2-test`
Detectors: OCaml Opam CLI, OCaml Opam Lock
Search depth: 2 (default)
