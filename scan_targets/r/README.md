# R Scan Target: rstudio/shiny

**Repo:** https://github.com/rstudio/shiny
**Cloned to:** /opt/scan_targets/r/shiny

## Why this project

Shiny is RStudio's R web framework. It uses packrat for reproducible dependency management
and should have a committed `packrat/packrat.lock`. This is exactly what the R Packrat Lock
detector requires. R is installed in the container via `dnf install -y R`.

## Verification note

The upstream `rstudio/shiny` repo may not always include a committed `packrat.lock`. Before
scanning, verify:

```
ls /opt/scan_targets/r/shiny/packrat/packrat.lock
```

If the file is missing, substitute `rstudio/packrat` as the target (it is the packrat
reference implementation and always includes a `packrat.lock`). Alternatively, generate
one from within the container:

```
cd /opt/scan_targets/r/shiny
Rscript -e "install.packages('packrat', repos='https://cran.r-project.org'); packrat::init(); packrat::snapshot()"
```

## Pre-scan steps

No setup required if `packrat.lock` exists. Detect parses it statically.

## Recommended scan.sh invocation

```
scan.sh --r
```

Detect project name: `r-detect-11.4.2-test`
Detectors: R Packrat Lock
Search depth: 2 (default)
