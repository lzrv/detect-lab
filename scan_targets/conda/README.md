# Conda Scan Target: Anaconda-Platform/anaconda-client

**Repo:** https://github.com/Anaconda-Platform/anaconda-client
**Cloned to:** /opt/scan_targets/conda/anaconda-client

## Why this project

anaconda-client provides an `environment.yml` that conda can use to create an environment,
which is the prerequisite for the Conda CLI detector. It has a well-defined set of conda
dependencies and represents a real-world conda workflow.

## Pre-scan steps (REQUIRED)

The Conda CLI detector requires an active conda environment. You must create one before
running Detect:

```
cd /opt/scan_targets/conda/anaconda-client
conda env create -f environment.yml -n detect-conda-test --quiet
conda activate detect-conda-test
```

If the environment already exists from a prior run:

```
conda env remove -n detect-conda-test -y
conda env create -f environment.yml -n detect-conda-test --quiet
conda activate detect-conda-test
```

Run the scan from inside the activated environment so Detect can call `conda list`.

## Recommended scan.sh invocation

```
scan.sh --conda
```

Detect project name: `conda-detect-11.4.2-test`
Detectors: Conda CLI
Search depth: 2 (default)

> Note: The conda CLI detector calls `conda list --json` in the scan directory's active
> environment. Without the `conda env create` step above, the detector will not find any
> packages to report.
