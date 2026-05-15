# Composer Scan Target: laravel/laravel

**Repo:** https://github.com/laravel/laravel
**Cloned to:** /opt/scan_targets/composer/laravel

## Why this project

Laravel is the most-used PHP framework and is itself a Composer project. Its `composer.json`
is a clean, well-structured manifest. While `composer.lock` is not committed in the upstream
template repo (it is generated per-project), Detect will use the Composer CLI detector to
resolve dependencies by running `composer install`. PHP and Composer are installed in the
container.

## Pre-scan steps (REQUIRED for CLI detection)

`composer.lock` is not committed in the Laravel template. The Composer Lock detector will
not fire without it. Generate the lockfile first:

```
cd /opt/scan_targets/composer/laravel
composer install --no-scripts --no-plugins --quiet
```

This creates `composer.lock` in place, enabling the Composer Lock detector on the next run.

## Recommended scan.sh invocation

```
scan.sh --composer
```

Detect project name: `composer-detect-11.4.2-test`
Detectors: Composer Lock (after `composer install`), Composer CLI
Search depth: 2 (default)
