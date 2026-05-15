# detect-lab Expansion Plan

## Context

**Repo:** `~/src/detect-lab`  
**Goal:** Modernize the lab container (Debian → Fedora 44, Detect 11.2.1 → 11.4.2) and expand it into a comprehensive multi-PM lab — every package manager Detect supports gets an installed toolchain and a representative open-source scan target. A unified wrapper script ties it all together.

**Why Fedora:** User standardizes on Fedora/RHEL across lab environments and AMIs. Most BD SCA customers run RHEL-based distros, so Fedora coverage validates more real-world scanner paths than Debian.

---

## Current State (snapshot)

| Item | Current |
|------|---------|
| Base image | `debian:trixie` |
| Detect version | 11.2.1 |
| Package managers installed | Node.js / npm only |
| Scan targets (in container) | Tiredful-API, detect source, express.js |
| `scan_targets/` dir in repo | Does not exist |
| Wrapper script | `detect.sh` — minimal, reads `env.sh`, runs JAR |
| docker-compose | None |

---

## Architecture Decisions

### Layer strategy — keep layers split, do NOT squash

For a lab image, build-cache speed during iteration outweighs image size compactness. One RUN block per package manager toolchain means:
- Changing a single toolchain (e.g., upgrading Go) rebuilds only that layer and everything after it
- Unrelated toolchains hit cache and don't re-download

Layer count estimate: ~55 RUN blocks. Docker's hard limit is 127. Not a problem.

**Trade-off acknowledged:** Final image will be large (estimated 6–12 GB uncompressed). This is by design — it's a lab, not a production image. No multi-stage build needed.

### Scan targets — cloned in Dockerfile, documented locally

- `scan_targets/` directory in the repo contains a `README.md` per package manager with the chosen project's URL, why it was chosen, and any pre-scan setup steps.
- The Dockerfile `git clone`s each target into `/opt/scan_targets/<pm>/` during build.
- This keeps the repo small while making intent readable.

### Wrapper script — environment-variable-native

Detect's standard env vars (`BLACKDUCK_URL`, `BLACKDUCK_API_TOKEN`) are the primary interface. CLI flags (`--url`, `--token`) are supported as overrides. The `--all` flag runs all PM scans sequentially and creates per-PM projects on the target BD SCA instance.

---

## Phase 1 — Fedora Base + Detect Upgrade

**Files changed:** `Dockerfile`

### 1.1 Switch base image

```dockerfile
FROM fedora:44
```

### 1.2 Replace apt-get with dnf

Replace every `apt-get` call with `dnf`. Key Fedora package name differences:

| Debian name | Fedora equivalent |
|------------|-------------------|
| `openjdk-21-jdk` | `java-21-openjdk-devel` |
| `nodejs` | `nodejs` (same, in Fedora repos) |
| `npm` | `npm` (included with nodejs or separate) |
| `git` | `git` |
| `curl wget vim zip` | same names |

Initial system layer:
```dockerfile
RUN dnf update -y && \
    dnf install -y \
        git curl wget vim zip unzip tar \
        java-21-openjdk-devel \
        which findutils procps-ng && \
    dnf clean all
```

### 1.3 Update Detect JAR

```dockerfile
RUN mkdir -p /opt/blackduck && \
    wget -O /opt/blackduck/detect-11.4.2.jar \
    https://repo.blackduck.com/bds-integrations-release/com/blackduck/integration/detect/11.4.2/detect-11.4.2.jar
```

---

## Phase 2 — Package Manager Toolchain Installation

Each PM gets its own clearly-labeled Dockerfile section. Order is arbitrary; within a section, group into as few RUN blocks as needed for readability while still preserving layer-cache granularity.

### 2.1 JavaScript / Node.js (npm, pnpm, yarn, lerna)

```dockerfile
# --- JavaScript / Node.js ---
RUN dnf install -y nodejs npm && dnf clean all
RUN npm install -g pnpm yarn lerna
```

Detectors covered: NPM Package Lock, NPM CLI, Pnpm Lock, Yarn Lock, Lerna CLI.

### 2.2 Python ecosystem (pip, pipenv, poetry, setuptools, uv, conda)

```dockerfile
# --- Python ---
RUN dnf install -y python3 python3-pip python3-devel && dnf clean all
RUN pip3 install --no-cache-dir pipenv poetry uv
# Miniconda (for conda CLI detector)
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/miniconda && \
    rm /tmp/miniconda.sh
ENV PATH="/opt/miniconda/bin:$PATH"
```

Detectors covered: PIP Native Inspector, PIP Requirements Parse, Pipfile Lock, Pipenv CLI, Poetry Lock, Setuptools CLI, UV CLI, UV Lock, Conda CLI.

### 2.3 Java / JVM — Maven, Gradle, SBT (Scala)

Java 21 is already installed in Phase 1.

```dockerfile
# --- Maven ---
RUN dnf install -y maven && dnf clean all

# --- Gradle (no Fedora package, install via direct download) ---
ARG GRADLE_VERSION=8.13
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -O /tmp/gradle.zip && \
    unzip -q /tmp/gradle.zip -d /opt && \
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle && \
    rm /tmp/gradle.zip

# --- SBT (Scala Build Tool) ---
RUN curl -L https://github.com/sbt/sbt/releases/download/v1.10.11/sbt-1.10.11.tgz | \
    tar xz -C /opt && \
    ln -s /opt/sbt/bin/sbt /usr/local/bin/sbt
```

Detectors covered: Gradle Native Inspector, Maven CLI, Sbt Native Inspector, Ivy Build Parse.

### 2.4 Go

```dockerfile
# --- Go ---
RUN dnf install -y golang && dnf clean all
```

Detectors covered: GoMod CLI, Go Mod File.

### 2.5 Rust / Cargo

```dockerfile
# --- Rust / Cargo ---
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --no-modify-path
ENV PATH="/root/.cargo/bin:$PATH"
```

Detectors covered: Cargo CLI, Cargo Lock.

### 2.6 C# / .NET (NuGet)

Microsoft packages for Fedora require the Microsoft repo:

```dockerfile
# --- .NET SDK ---
RUN curl -sSL https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/prod.repo \
    -o /etc/yum.repos.d/microsoft-prod.repo
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    dnf install -y dotnet-sdk-9.0 && dnf clean all
```

Detectors covered: NuGet Solution Native Inspector, NuGet Project Native Inspector.

### 2.7 Ruby + Bundler

```dockerfile
# --- Ruby + Bundler ---
RUN dnf install -y ruby ruby-devel rubygems && dnf clean all
RUN gem install bundler
```

Detectors covered: Gemfile Lock, Gemspec Parse.

### 2.8 PHP + Composer

```dockerfile
# --- PHP + Composer ---
RUN dnf install -y php php-cli php-json && dnf clean all
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
```

Detectors covered: Composer Lock.

### 2.9 C/C++ — Conan

```dockerfile
# --- Conan (C/C++) ---
RUN pip3 install --no-cache-dir conan
```

Detectors covered: Conan 1 CLI, Conan 2 CLI, Conan Lock.

### 2.10 Dart

```dockerfile
# --- Dart ---
ARG DART_VERSION=3.7.3
RUN wget -q https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/linux_packages/dart_${DART_VERSION}-1_amd64.rpm \
    -O /tmp/dart.rpm && \
    rpm -i /tmp/dart.rpm && \
    rm /tmp/dart.rpm
```

Detectors covered: Dart CLI, Dart PubSpec Lock.

### 2.11 Erlang + Rebar3

```dockerfile
# --- Erlang + Rebar3 ---
RUN dnf install -y erlang && dnf clean all
RUN wget -q https://s3.amazonaws.com/rebar3/rebar3 -O /usr/local/bin/rebar3 && \
    chmod +x /usr/local/bin/rebar3
```

Detectors covered: Erlang Rebar CLI.

### 2.12 OCaml + Opam

```dockerfile
# --- OCaml + Opam ---
RUN dnf install -y opam && dnf clean all
RUN opam init --disable-sandboxing -y && eval $(opam env)
```

Detectors covered: OCaml Opam CLI, OCaml Opam Lock.

### 2.13 Perl + CPAN

```dockerfile
# --- Perl + CPAN ---
RUN dnf install -y perl perl-CPAN perl-App-cpanminus && dnf clean all
```

Detectors covered: Perl CPAN CLI.

### 2.14 R + Packrat

```dockerfile
# --- R ---
RUN dnf install -y R && dnf clean all
```

Detectors covered: R Packrat Lock.

### 2.15 Bazel

```dockerfile
# --- Bazel ---
ARG BAZEL_VERSION=8.2.1
RUN wget -q https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64 \
    -O /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel
```

Detectors covered: Bazel CLI.

### 2.16 Swift (optional, large ~2GB layer)

Swift for Linux is available but adds ~2 GB. Include as commented-out section for opt-in:

```dockerfile
# --- Swift (optional, ~2GB) ---
# ARG SWIFT_VERSION=5.10.1
# RUN wget -q https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubi9/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubi9.tar.gz ...
```

Detectors covered (when enabled): Swift CLI, Swift Lock.

### 2.17 Bitbake (documentation only)

Bitbake requires a Yocto build environment that is impractical inside a general container (requires matching host kernel, large build dependencies, sourced environment scripts). Include a commented stub with a pointer to the Detect Bitbake setup docs. No toolchain installed by default.

---

## Phase 3 — Scan Targets

### 3.1 Local repo structure

Create `scan_targets/` directory in the repo with one subdirectory per package manager. Each contains a `README.md` with:
- chosen project name and URL
- why it was chosen
- pre-scan steps (e.g., `npm install`, `pip install -r requirements.txt`)
- expected Detect flags

```
scan_targets/
├── npm/README.md          → expressjs/express
├── pnpm/README.md         → vitejs/vite
├── yarn/README.md         → facebook/jest
├── pip/README.md          → psf/requests
├── poetry/README.md       → python-poetry/poetry
├── pipenv/README.md       → pypa/pipenv
├── uv/README.md           → astral-sh/ruff
├── conda/README.md        → anaconda-platform/anaconda-client
├── maven/README.md        → spring-projects/spring-petclinic
├── gradle/README.md       → square/okhttp
├── sbt/README.md          → scala/scala-parser-combinators
├── go/README.md           → cli/cli
├── cargo/README.md        → sharkdp/bat
├── nuget/README.md        → dotnet/eShopOnWeb
├── gemfile/README.md      → sinatra/sinatra
├── composer/README.md     → laravel/laravel
├── conan/README.md        → conan-io/examples
├── dart/README.md         → dart-lang/pub
├── bazel/README.md        → abseil/abseil-cpp
├── erlang/README.md       → ninenines/cowboy
├── ocaml/README.md        → mirage/mirage
├── perl/README.md         → libwww-perl/libwww-perl
├── r/README.md            → rstudio/shiny (packrat.lock present)
└── bitbake/README.md      → documentation only
```

### 3.2 Clone targets in Dockerfile

One `RUN git clone` block per PM, labeled clearly. Use `--depth=1` on all clones to minimize image size:

```dockerfile
# --- Scan Targets ---
RUN git clone --depth=1 https://github.com/expressjs/express /opt/scan_targets/npm/express
RUN git clone --depth=1 https://github.com/vitejs/vite /opt/scan_targets/pnpm/vite
RUN git clone --depth=1 https://github.com/facebook/jest /opt/scan_targets/yarn/jest
RUN git clone --depth=1 https://github.com/psf/requests /opt/scan_targets/pip/requests
RUN git clone --depth=1 https://github.com/python-poetry/poetry /opt/scan_targets/poetry/poetry
RUN git clone --depth=1 https://github.com/pypa/pipenv /opt/scan_targets/pipenv/pipenv
RUN git clone --depth=1 https://github.com/astral-sh/ruff /opt/scan_targets/uv/ruff
RUN git clone --depth=1 https://github.com/Anaconda-Platform/anaconda-client /opt/scan_targets/conda/anaconda-client
RUN git clone --depth=1 https://github.com/spring-projects/spring-petclinic /opt/scan_targets/maven/spring-petclinic
RUN git clone --depth=1 https://github.com/square/okhttp /opt/scan_targets/gradle/okhttp
RUN git clone --depth=1 https://github.com/scala/scala-parser-combinators /opt/scan_targets/sbt/scala-parser-combinators
RUN git clone --depth=1 https://github.com/cli/cli /opt/scan_targets/go/cli
RUN git clone --depth=1 https://github.com/sharkdp/bat /opt/scan_targets/cargo/bat
RUN git clone --depth=1 https://github.com/dotnet-architecture/eShopOnWeb /opt/scan_targets/nuget/eShopOnWeb
RUN git clone --depth=1 https://github.com/sinatra/sinatra /opt/scan_targets/gemfile/sinatra
RUN git clone --depth=1 https://github.com/laravel/laravel /opt/scan_targets/composer/laravel
RUN git clone --depth=1 https://github.com/conan-io/examples /opt/scan_targets/conan/examples
RUN git clone --depth=1 https://github.com/dart-lang/pub /opt/scan_targets/dart/pub
RUN git clone --depth=1 https://github.com/abseil/abseil-cpp /opt/scan_targets/bazel/abseil-cpp
RUN git clone --depth=1 https://github.com/ninenines/cowboy /opt/scan_targets/erlang/cowboy
RUN git clone --depth=1 https://github.com/mirage/mirage /opt/scan_targets/ocaml/mirage
RUN git clone --depth=1 https://github.com/libwww-perl/libwww-perl /opt/scan_targets/perl/libwww-perl
RUN git clone --depth=1 https://github.com/rstudio/shiny /opt/scan_targets/r/shiny
```

---

## Phase 4 — Wrapper Script (`scan.sh`)

**File:** `scan.sh` (replaces `detect.sh`)

### Interface

```
Usage: scan.sh [OPTIONS]

Environment variables (standard Detect):
  BLACKDUCK_URL        BD SCA instance URL
  BLACKDUCK_API_TOKEN  BD SCA API token

Options:
  --url URL            Override BLACKDUCK_URL
  --token TOKEN        Override BLACKDUCK_API_TOKEN
  --all                Run all supported package managers
  --pm PM              Run single package manager (e.g. --pm npm)
  --detect-version V   Detect JAR version tag used in project names (default: 11.4.2)
  --trust-cert         Pass --blackduck.trust.cert=true
  -h, --help           Show this help

Package manager shortcuts:
  --npm, --pnpm, --yarn, --pip, --poetry, --pipenv, --uv, --conda,
  --maven, --gradle, --sbt, --go, --cargo, --nuget, --gemfile,
  --composer, --conan, --dart, --bazel, --erlang, --ocaml, --perl, --r
```

### Project naming convention

`<pm>-detect-<detect-version>-test`

Examples: `npm-detect-11.4.2-test`, `maven-detect-11.4.2-test`, `bazel-detect-11.4.2-test`

### Implementation sketch

```bash
#!/usr/bin/env bash
set -euo pipefail

DETECT_VERSION="11.4.2"
DETECT_JAR="/opt/blackduck/detect-${DETECT_VERSION}.jar"
SCAN_ROOT="/opt/scan_targets"
BD_URL="${BLACKDUCK_URL:-}"
BD_TOKEN="${BLACKDUCK_API_TOKEN:-}"
TRUST_CERT="false"

run_scan() {
    local pm="$1"
    local source_path="$2"
    local project_name="${pm}-detect-${DETECT_VERSION}-test"
    echo "=== Scanning: $pm → $project_name ==="
    java -jar "$DETECT_JAR" \
        --blackduck.url="$BD_URL" \
        --blackduck.api.token="$BD_TOKEN" \
        --blackduck.trust.cert="$TRUST_CERT" \
        --detect.source.path="$source_path" \
        --detect.project.name="$project_name" \
        --detect.project.version.name="${DETECT_VERSION}" \
        --detect.tools=DETECTOR \
        --detect.detector.search.depth=2 \
        --detect.detector.search.continue=true
}

declare -A PM_PATHS=(
    [npm]="$SCAN_ROOT/npm/express"
    [pnpm]="$SCAN_ROOT/pnpm/vite"
    [yarn]="$SCAN_ROOT/yarn/jest"
    [pip]="$SCAN_ROOT/pip/requests"
    [poetry]="$SCAN_ROOT/poetry/poetry"
    [pipenv]="$SCAN_ROOT/pipenv/pipenv"
    [uv]="$SCAN_ROOT/uv/ruff"
    [conda]="$SCAN_ROOT/conda/anaconda-client"
    [maven]="$SCAN_ROOT/maven/spring-petclinic"
    [gradle]="$SCAN_ROOT/gradle/okhttp"
    [sbt]="$SCAN_ROOT/sbt/scala-parser-combinators"
    [go]="$SCAN_ROOT/go/cli"
    [cargo]="$SCAN_ROOT/cargo/bat"
    [nuget]="$SCAN_ROOT/nuget/eShopOnWeb"
    [gemfile]="$SCAN_ROOT/gemfile/sinatra"
    [composer]="$SCAN_ROOT/composer/laravel"
    [conan]="$SCAN_ROOT/conan/examples"
    [dart]="$SCAN_ROOT/dart/pub"
    [bazel]="$SCAN_ROOT/bazel/abseil-cpp"
    [erlang]="$SCAN_ROOT/erlang/cowboy"
    [ocaml]="$SCAN_ROOT/ocaml/mirage"
    [perl]="$SCAN_ROOT/perl/libwww-perl"
    [r]="$SCAN_ROOT/r/shiny"
)
```

---

## Phase 5 — Supporting Files

### 5.1 `detect.sh` → remove or keep as shim

`scan.sh` is the new entry point. `detect.sh` can be removed or kept as a thin backward-compat shim pointing to `scan.sh`.

### 5.2 Update `application.properties`

Update JAR reference: `detect-11.2.1.jar` → `detect-11.4.2.jar`.

### 5.3 Rewrite `README.md`

Document: build command, `docker run` with env vars, `scan.sh --all` usage, per-PM examples, expected image size (~8–12 GB).

### 5.4 Migrate `env.sh`

`env.sh` uses `BD_HOST` / `BD_TOKEN`. Migrate to Detect's native env vars `BLACKDUCK_URL` / `BLACKDUCK_API_TOKEN`, or document both and map them in `scan.sh`.

---

## Implementation Order (for agent loop execution)

| Step | Task | Files |
|------|------|-------|
| 1 | Fedora base image + system packages | `Dockerfile` |
| 2 | Detect 11.4.2 JAR download | `Dockerfile` |
| 3 | JS toolchain (Node.js, pnpm, yarn, lerna) | `Dockerfile` |
| 4 | Python toolchain (pip, pipenv, poetry, uv, conda/Miniconda) | `Dockerfile` |
| 5 | JVM toolchain (Maven, Gradle, SBT) | `Dockerfile` |
| 6 | Go | `Dockerfile` |
| 7 | Rust / Cargo | `Dockerfile` |
| 8 | .NET SDK (NuGet) | `Dockerfile` |
| 9 | Ruby + Bundler | `Dockerfile` |
| 10 | PHP + Composer | `Dockerfile` |
| 11 | Conan (C/C++) | `Dockerfile` |
| 12 | Dart | `Dockerfile` |
| 13 | Erlang + Rebar3 | `Dockerfile` |
| 14 | OCaml + Opam | `Dockerfile` |
| 15 | Perl + CPAN | `Dockerfile` |
| 16 | R | `Dockerfile` |
| 17 | Bazel | `Dockerfile` |
| 18 | Scan target git clones (23 repos) | `Dockerfile` |
| 19 | Local `scan_targets/` dirs + per-PM READMEs | repo |
| 20 | `scan.sh` wrapper script | `scan.sh` |
| 21 | Update `application.properties`, `env.sh`, `README.md` | config |
| 22 | `docker build` smoke test | — |
| 23 | Per-PM scan validation inside container | — |

---

## Verification

1. `docker build -t detect-lab:11.4.2 .` — completes without error.
2. Toolchain check: `docker run --rm detect-lab:11.4.2 bash -c "java -version && node --version && python3 --version && go version && cargo --version && dotnet --version && ruby --version && php --version && dart --version && rebar3 version && bazel version"`
3. Detect JAR: `docker run --rm detect-lab:11.4.2 java -jar /opt/blackduck/detect-11.4.2.jar --help`
4. Single PM: `docker run --rm -e BLACKDUCK_URL=... -e BLACKDUCK_API_TOKEN=... detect-lab:11.4.2 bash -c "cd /opt/blackduck && ./scan.sh --npm"`
5. Full sweep: `docker run --rm -e BLACKDUCK_URL=... -e BLACKDUCK_API_TOKEN=... detect-lab:11.4.2 bash -c "cd /opt/blackduck && ./scan.sh --all"`
6. Confirm 23 projects in BD SCA instance, each named `<pm>-detect-11.4.2-test`.

---

## Open Items

- **eShopOnWeb**: verify `.sln`/`.csproj` is at a depth reachable with `--detect.detector.search.depth=2`.
- **conda target**: `anaconda-client` has `environment.yml` but Conda CLI detector requires `conda env create` to have been run. Document pre-scan step in `scan_targets/conda/README.md`.
- **R/packrat**: verify `rstudio/shiny` has a committed `packrat.lock`; if not, substitute `rstudio/packrat`.
- **Bitbake**: no scan target cloned; README only. Yocto setup is impractical in a general container.
- **Swift**: commented out by default (~2 GB layer); user can uncomment to enable.
- **CocoaPods**: macOS/iOS only; not included.
- **.NET on Fedora**: Microsoft repo `.repo` file URL uses `%fedora` RPM macro — validate this resolves correctly at build time for Fedora 44.
