# CLAUDE.md — detect-lab

## Project purpose

Lab container for running Black Duck Detect 11.4.2 against 23 package managers. Not a production image — image size (~8-12 GB) is intentional. Based on Fedora 44, amd64 only.

## Key architecture

- One Dockerfile layer per PM toolchain for cache granularity during iteration
- 23 open-source repos cloned at build time into `/opt/scan_targets/<pm>/<repo>`
- `scan.sh` is the primary entry point; `detect.sh` is a host-side backward-compat shim only (not copied into the image)
- `application.properties` at `/opt/blackduck/application.properties` sets Spring Boot defaults; CLI args from `scan.sh` override them
- Detect JAR is at `/opt/blackduck/detect-11.4.2.jar`
- WORKDIR inside the container is `/opt/blackduck`

## scan.sh conventions

- Requires bash 4.0+ (uses `declare -A` associative arrays)
- PM dispatch: `declare -A PM_PATHS` maps PM name to scan target path; `ALL_PMS` array controls `--all` order
- `set -euo pipefail` is active; scan loop uses `|| { ... failed_pms+=(...); }` to continue on per-PM failure
- No `eval`, no user-controlled string expansion
- Credentials (`BLACKDUCK_URL`, `BLACKDUCK_API_TOKEN`) are passed via environment variables, not CLI args — `application.properties` expands them with Spring `${VAR}` syntax

## Env var naming

- Standard Detect env vars: `BLACKDUCK_URL` and `BLACKDUCK_API_TOKEN`
- `env.sh` is a local convenience template for setting credentials before `docker run`; it is not sourced by anything automatically

## Adding a new PM

1. Add toolchain `RUN` block to Dockerfile (keep as a separate layer)
2. Add entry to `PM_PATHS` and `ALL_PMS` in `scan.sh`
3. Add `RUN git clone --depth=1 <repo> /opt/scan_targets/<pm>/<repo>` to Dockerfile
4. Create `scan_targets/<pm>/README.md` documenting why the target, pre-scan steps, and recommended invocation

## Scan targets with mandatory pre-scan steps

- **conda**: must run `conda env create -f environment.yml -n detect-conda-test` and `source /opt/miniconda/etc/profile.d/conda.sh && conda activate detect-conda-test` before scanning
- **composer**: must run `composer install --no-scripts --no-plugins` in the scan target dir to generate `composer.lock`

## Build and validate

```bash
docker build -t detect-lab:11.4.2 .
docker run --rm detect-lab:11.4.2 java -jar /opt/blackduck/detect-11.4.2.jar --help | head -5
docker run --rm detect-lab:11.4.2 ./scan.sh --help
```

## Platform constraint

Image is amd64-only (`FROM --platform=linux/amd64`). Miniconda, Dart, and Bazel installers are all x86_64. Do not remove the `--platform` flag.
