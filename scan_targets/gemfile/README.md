# Gemfile Scan Target: sinatra/sinatra

**Repo:** https://github.com/sinatra/sinatra
**Cloned to:** /opt/scan_targets/gemfile/sinatra

## Why this project

Sinatra is a classic Ruby DSL for web applications. It has a `Gemfile` and `Gemfile.lock`
committed at the repo root, which is the canonical input for the Gemfile Lock detector.
The project also has a `.gemspec` exercising the Gemspec Parse detector. Ruby and Bundler
are installed in the container.

## Pre-scan steps

No setup required. Both `Gemfile.lock` and the `.gemspec` are committed and parsed directly
by Detect. For Bundler CLI detection (optional):

```
cd /opt/scan_targets/gemfile/sinatra
bundle install --quiet
```

## Recommended scan.sh invocation

```
scan.sh --gemfile
```

Detect project name: `gemfile-detect-11.4.2-test`
Detectors: Gemfile Lock, Gemspec Parse
Search depth: 2 (default)
