# Plan: detect-lab Fedora Migration and Multi-PM Expansion

## Overview

Modernize the detect-lab container from Debian to Fedora 44, upgrade Detect CLI from 11.2.1
to 11.4.2, and expand the lab into a comprehensive multi-package-manager environment covering
every detector supported by Detect 11.4.x.

**Architecture decisions:**
- Base image: `fedora:44` (replaces `debian:trixie`). All `apt-get` calls become `dnf`.
- Detect JAR: 11.4.2 downloaded from `repo.blackduck.com/bds-integrations-release/...`.
- Layer strategy: one RUN block per PM toolchain — ~55 layers total, well under Docker's 127
  limit. Keeps build cache granular so changing one toolchain doesn't invalidate others.
- Image size: ~8–12 GB uncompressed by design. This is a lab, not a production image.
- Scan targets: cloned with `--depth=1` in Dockerfile into `/opt/scan_targets/<pm>/<repo>`.
  Local `scan_targets/` tree in the repo holds per-PM READMEs with rationale and pre-scan steps.
- Wrapper script `scan.sh` uses standard Detect env vars (`BLACKDUCK_URL`, `BLACKDUCK_API_TOKEN`).
  `--all` flag scans all PMs and creates projects named `<pm>-detect-11.4.2-test` on the instance.

**Key Fedora package name differences from Debian:**
- `openjdk-21-jdk` → `java-21-openjdk-devel`
- `apt-get install` → `dnf install -y` + `dnf clean all` in same layer

**Open items to verify during implementation:**
- eShopOnWeb: confirm `.sln`/`.csproj` is reachable at `--detect.detector.search.depth=2`
- R/packrat: verify `rstudio/shiny` has a committed `packrat.lock`; substitute `rstudio/packrat` if not
- conda target: `anaconda-client` needs `conda env create` before Conda CLI detector fires — document in README
- .NET on Fedora: Microsoft repo `.repo` URL uses `%fedora` RPM macro — validate for Fedora 44
- Bitbake: no scan target cloned; stub + README only (Yocto impractical in a general container)
- Swift: commented out by default (~2 GB layer); user can uncomment to enable
- CocoaPods: macOS/iOS only; not included

## Validation Commands

- `docker build -t detect-lab:11.4.2 .`
- `docker run --rm detect-lab:11.4.2 java -jar /opt/blackduck/detect-11.4.2.jar --help | head -5`

---

### Task 1: Switch to Fedora base image and update system packages

Replace the `debian:trixie` base with `fedora:44`. Rewrite the initial RUN blocks using `dnf`
instead of `apt-get`. Install Java 21 (`java-21-openjdk-devel`) and all base utilities.
Download the Detect 11.4.2 JAR into `/opt/blackduck/`. Remove all old apt-based layers.

- [x] Change `FROM debian:trixie` to `FROM fedora:44`
- [x] Replace apt system packages RUN block with `dnf update -y && dnf install -y git curl wget vim zip unzip tar java-21-openjdk-devel which findutils procps-ng && dnf clean all`
- [x] Update Detect JAR download to 11.4.2: `wget -O /opt/blackduck/detect-11.4.2.jar https://repo.blackduck.com/bds-integrations-release/com/blackduck/integration/detect/11.4.2/detect-11.4.2.jar`
- [x] Remove all remaining `apt-get` lines from the Dockerfile

### Task 2: Add JavaScript toolchain (npm, pnpm, yarn, lerna)

Install Node.js and npm via `dnf`. Install pnpm, yarn, and lerna globally via npm.
Detectors covered: NPM Package Lock, NPM CLI, Pnpm Lock, Yarn Lock, Lerna CLI.

- [x] Add `RUN dnf install -y nodejs npm && dnf clean all`
- [x] Add `RUN npm install -g pnpm yarn lerna`

### Task 3: Add Python toolchain (pip, pipenv, poetry, uv, conda)

Install Python 3 + pip via dnf. Install pipenv, poetry, and uv via pip3.
Install Miniconda for the conda CLI detector and add `/opt/miniconda/bin` to PATH.
Detectors covered: PIP, Pipfile Lock, Pipenv CLI, Poetry Lock, Setuptools, UV CLI, UV Lock, Conda CLI.

- [x] Add `RUN dnf install -y python3 python3-pip python3-devel && dnf clean all`
- [x] Add `RUN pip3 install --no-cache-dir pipenv poetry uv`
- [x] Add Miniconda download and silent install into `/opt/miniconda`
- [x] Add `ENV PATH="/opt/miniconda/bin:$PATH"`

### Task 4: Add JVM toolchain (Maven, Gradle, SBT)

Java 21 is already installed in Task 1. Install Maven via dnf. Download and install Gradle 8.13
manually (no Fedora package). Download and install SBT 1.10.11 from GitHub releases.
Detectors covered: Maven CLI, Gradle Native Inspector, Sbt Native Inspector, Ivy Build Parse.

- [x] Add `RUN dnf install -y maven && dnf clean all`
- [x] Add ARG GRADLE_VERSION=8.13 and RUN to wget Gradle zip, unzip into /opt, symlink to /usr/local/bin/gradle, remove zip
- [x] Add RUN to curl SBT 1.10.11 tgz from GitHub, extract to /opt, symlink to /usr/local/bin/sbt

### Task 5: Add Go and Rust/Cargo toolchains

Install Go via dnf. Install Rust toolchain via rustup (non-interactive). Add cargo to PATH.
Detectors covered: GoMod CLI, Go Mod File, Cargo CLI, Cargo Lock.

- [x] Add `RUN dnf install -y golang && dnf clean all`
- [x] Add `RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path`
- [x] Add `ENV PATH="/root/.cargo/bin:$PATH"`

### Task 6: Add .NET SDK (NuGet)

Add the Microsoft package repo for Fedora, import the GPG key, and install `dotnet-sdk-9.0`.
Detectors covered: NuGet Solution Native Inspector, NuGet Project Native Inspector.

- [x] Add RUN to curl the Microsoft Fedora prod.repo file into /etc/yum.repos.d/microsoft-prod.repo using `$(rpm -E %fedora)` for the version
- [x] Add `RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && dnf install -y dotnet-sdk-9.0 && dnf clean all`

### Task 7: Add Ruby, PHP, and Conan toolchains

Install Ruby + Bundler via dnf/gem. Install PHP + Composer via dnf and the Composer installer.
Install Conan (C/C++) via pip3 (Python already installed in Task 3).
Detectors covered: Gemfile Lock, Gemspec Parse, Composer Lock, Conan 1 CLI, Conan 2 CLI, Conan Lock.

- [x] Add `RUN dnf install -y ruby ruby-devel rubygems && dnf clean all`
- [x] Add `RUN gem install bundler`
- [x] Add `RUN dnf install -y php php-cli php-json && dnf clean all`
- [x] Add `RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer`
- [x] Add `RUN pip3 install --no-cache-dir conan`

### Task 8: Add Dart, Erlang/Rebar3, and OCaml/Opam toolchains

Install Dart via RPM package from dart.dev. Install Erlang via dnf and rebar3 binary from S3.
Install OCaml + opam via dnf and run `opam init --disable-sandboxing -y`.
Detectors covered: Dart CLI, Dart PubSpec Lock, Erlang Rebar CLI, OCaml Opam CLI, OCaml Opam Lock.

- [x] Add ARG DART_VERSION=3.7.3 and RUN to wget the Dart amd64 RPM from dart-archive on GCS, rpm -i it, remove it
- [x] Add `RUN dnf install -y erlang && dnf clean all`
- [x] Add `RUN wget -q https://s3.amazonaws.com/rebar3/rebar3 -O /usr/local/bin/rebar3 && chmod +x /usr/local/bin/rebar3`
- [x] Add `RUN dnf install -y opam && dnf clean all`
- [x] Add `RUN opam init --disable-sandboxing -y`

### Task 9: Add Perl, R, and Bazel toolchains; add Swift and Bitbake stubs

Install Perl + cpanm via dnf. Install R via dnf. Download Bazel 8.2.1 binary from GitHub releases.
Add commented-out Swift block (opt-in, ~2 GB). Add commented Bitbake stub with documentation note.
Detectors covered: Perl CPAN CLI, R Packrat Lock, Bazel CLI.

- [x] Add `RUN dnf install -y perl perl-CPAN perl-App-cpanminus && dnf clean all`
- [x] Add `RUN dnf install -y R && dnf clean all`
- [x] Add ARG BAZEL_VERSION=8.2.1 and RUN to wget Bazel binary into /usr/local/bin/bazel, chmod +x
- [x] Add commented-out Swift install block with ARG SWIFT_VERSION and wget from swift.org
- [x] Add commented Bitbake stub with a note that Yocto setup is impractical in a general container

### Task 10: Add scan target git clones to Dockerfile

Add one `RUN git clone --depth=1` per package manager into `/opt/scan_targets/<pm>/<repo>`.
23 repos total. Remove the old scan target clones (Tiredful-API, detect source, express).

- [x] Remove old git clone lines (Tiredful-API, detect source, express)
- [x] Add clone: `expressjs/express` → `/opt/scan_targets/npm/express`
- [x] Add clone: `vitejs/vite` → `/opt/scan_targets/pnpm/vite`
- [x] Add clone: `facebook/jest` → `/opt/scan_targets/yarn/jest`
- [x] Add clone: `psf/requests` → `/opt/scan_targets/pip/requests`
- [x] Add clone: `python-poetry/poetry` → `/opt/scan_targets/poetry/poetry`
- [x] Add clone: `pypa/pipenv` → `/opt/scan_targets/pipenv/pipenv`
- [x] Add clone: `astral-sh/ruff` → `/opt/scan_targets/uv/ruff`
- [x] Add clone: `Anaconda-Platform/anaconda-client` → `/opt/scan_targets/conda/anaconda-client`
- [x] Add clone: `spring-projects/spring-petclinic` → `/opt/scan_targets/maven/spring-petclinic`
- [x] Add clone: `square/okhttp` → `/opt/scan_targets/gradle/okhttp`
- [x] Add clone: `scala/scala-parser-combinators` → `/opt/scan_targets/sbt/scala-parser-combinators`
- [x] Add clone: `cli/cli` → `/opt/scan_targets/go/cli`
- [x] Add clone: `sharkdp/bat` → `/opt/scan_targets/cargo/bat`
- [x] Add clone: `dotnet-architecture/eShopOnWeb` → `/opt/scan_targets/nuget/eShopOnWeb`
- [x] Add clone: `sinatra/sinatra` → `/opt/scan_targets/gemfile/sinatra`
- [x] Add clone: `laravel/laravel` → `/opt/scan_targets/composer/laravel`
- [x] Add clone: `conan-io/examples` → `/opt/scan_targets/conan/examples`
- [x] Add clone: `dart-lang/pub` → `/opt/scan_targets/dart/pub`
- [x] Add clone: `abseil/abseil-cpp` → `/opt/scan_targets/bazel/abseil-cpp`
- [x] Add clone: `ninenines/cowboy` → `/opt/scan_targets/erlang/cowboy`
- [x] Add clone: `mirage/mirage` → `/opt/scan_targets/ocaml/mirage`
- [x] Add clone: `libwww-perl/libwww-perl` → `/opt/scan_targets/perl/libwww-perl`
- [x] Add clone: `rstudio/shiny` → `/opt/scan_targets/r/shiny`

### Task 11: Create local scan_targets/ directory with per-PM READMEs

Create `scan_targets/<pm>/README.md` for each of the 23 package managers plus a `bitbake/README.md`
stub. Each README must include: chosen project URL, why it was chosen, required pre-scan steps
inside the container, and the recommended `scan.sh` invocation.

- [ ] Create `scan_targets/npm/README.md` (expressjs/express)
- [ ] Create `scan_targets/pnpm/README.md` (vitejs/vite)
- [ ] Create `scan_targets/yarn/README.md` (facebook/jest)
- [ ] Create `scan_targets/pip/README.md` (psf/requests)
- [ ] Create `scan_targets/poetry/README.md` (python-poetry/poetry)
- [ ] Create `scan_targets/pipenv/README.md` (pypa/pipenv)
- [ ] Create `scan_targets/uv/README.md` (astral-sh/ruff)
- [ ] Create `scan_targets/conda/README.md` (Anaconda-Platform/anaconda-client — note conda env create pre-step)
- [ ] Create `scan_targets/maven/README.md` (spring-projects/spring-petclinic)
- [ ] Create `scan_targets/gradle/README.md` (square/okhttp)
- [ ] Create `scan_targets/sbt/README.md` (scala/scala-parser-combinators)
- [ ] Create `scan_targets/go/README.md` (cli/cli)
- [ ] Create `scan_targets/cargo/README.md` (sharkdp/bat)
- [ ] Create `scan_targets/nuget/README.md` (dotnet-architecture/eShopOnWeb)
- [ ] Create `scan_targets/gemfile/README.md` (sinatra/sinatra)
- [ ] Create `scan_targets/composer/README.md` (laravel/laravel)
- [ ] Create `scan_targets/conan/README.md` (conan-io/examples)
- [ ] Create `scan_targets/dart/README.md` (dart-lang/pub)
- [ ] Create `scan_targets/bazel/README.md` (abseil/abseil-cpp)
- [ ] Create `scan_targets/erlang/README.md` (ninenines/cowboy)
- [ ] Create `scan_targets/ocaml/README.md` (mirage/mirage)
- [ ] Create `scan_targets/perl/README.md` (libwww-perl/libwww-perl)
- [ ] Create `scan_targets/r/README.md` (rstudio/shiny — note packrat.lock verification)
- [ ] Create `scan_targets/bitbake/README.md` (documentation stub only)

### Task 12: Write scan.sh wrapper script

Write `scan.sh` to replace `detect.sh` as the main entry point. Must support:
- `BLACKDUCK_URL` / `BLACKDUCK_API_TOKEN` env vars (primary) and `--url` / `--token` overrides
- `--all` to run all 23 PMs sequentially
- Per-PM shortcuts (`--npm`, `--maven`, etc.) and `--pm <name>` generic form
- `--trust-cert` flag, `--detect-version` override, `-h`/`--help`
- Project naming: `<pm>-detect-11.4.2-test` with version from `--detect-version`
- Each scan uses `--detect.tools=DETECTOR --detect.detector.search.depth=2 --detect.detector.search.continue=true`
- `set -euo pipefail`; no shell injection (all args passed as separate words, no eval)

- [ ] Write `scan.sh` with shebang `#!/usr/bin/env bash` and `set -euo pipefail`
- [ ] Implement argument parsing (all flags listed above)
- [ ] Implement `run_scan()` function using associative array dispatch table for PM→path mapping
- [ ] Implement `--all` loop over all 23 PMs
- [ ] Add `chmod u+x scan.sh` entry to Dockerfile (replacing the detect.sh chmod)
- [ ] Add `COPY scan.sh .` to Dockerfile

### Task 13: Update supporting files

Update `application.properties`, `env.sh`, and `README.md` to reflect the new setup.
Remove `detect.sh` (replaced by `scan.sh`).

- [ ] Update `application.properties`: change `detect-11.2.1.jar` references to `detect-11.4.2.jar`
- [ ] Update `env.sh`: rename `BD_HOST` → `BLACKDUCK_URL` and `BD_TOKEN` → `BLACKDUCK_API_TOKEN`
- [ ] Remove `detect.sh` (or replace with one-line shim: `exec "$(dirname "$0")/scan.sh" "$@"`)
- [ ] Rewrite `README.md`: document `docker build`, `docker run` with env vars, `scan.sh --all`, per-PM examples, expected image size (~8–12 GB)
- [ ] Remove `COPY detect.sh .` from Dockerfile (already replaced by scan.sh in Task 12)
