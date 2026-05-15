# Perl Scan Target: libwww-perl/libwww-perl

**Repo:** https://github.com/libwww-perl/libwww-perl
**Cloned to:** /opt/scan_targets/perl/libwww-perl

## Why this project

libwww-perl (LWP) is the canonical Perl HTTP client library, distributed on CPAN. Its
`Makefile.PL` / `cpanfile` declares clear, well-known dependencies. It exercises the
Perl CPAN CLI detector, which calls `cpanm --installdeps` or `cpan` to resolve the
dependency tree. Perl, cpan, and cpanm (App::cpanminus) are all installed in the container.

## Pre-scan steps

For the CPAN CLI detector to resolve dependencies, install them first:

```
cd /opt/scan_targets/perl/libwww-perl
cpanm --installdeps . --notest --quiet
```

This downloads and installs all declared CPAN dependencies into the system Perl tree, making
them visible to Detect's `cpan list` queries.

## Recommended scan.sh invocation

```
scan.sh --perl
```

Detect project name: `perl-detect-11.4.2-test`
Detectors: Perl CPAN CLI
Search depth: 2 (default)
