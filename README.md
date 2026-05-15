# detect-lab

A lab container for testing [Black Duck Detect](https://documentation.blackduck.com/bundle/bd-hub/page/detectguide/DetectOverview.html) 11.4.2 across 23 package managers. Based on Fedora 44.

Expected image size: ~8–12 GB uncompressed (by design — this is a lab, not a production image).

## Build

```
docker build -t detect-lab:11.4.2 .
```

## Run

Set your Black Duck credentials as environment variables, then start a shell:

```
export BLACKDUCK_URL=https://your-bd-instance.example.com
export BLACKDUCK_API_TOKEN=your-api-token

docker run --rm \
  -e BLACKDUCK_URL \
  -e BLACKDUCK_API_TOKEN \
  -it detect-lab:11.4.2 bash
```

## Scanning

Inside the container, use `scan.sh`:

```
# Scan all 23 package managers sequentially
./scan.sh --all

# Scan a single package manager
./scan.sh --npm
./scan.sh --maven
./scan.sh --pm cargo

# Trust a self-signed cert
./scan.sh --all --trust-cert

# Override URL/token at runtime
./scan.sh --npm --url https://other-bd.example.com --token mytoken

# Override Detect version
./scan.sh --all --detect-version 11.5.0
```

Each PM scan creates a Black Duck project named `<pm>-detect-11.4.2-test`.

## Supported package managers

| Flag | Detector | Scan target |
|------|----------|-------------|
| `--npm` | NPM | expressjs/express |
| `--pnpm` | Pnpm Lock | vitejs/vite |
| `--yarn` | Yarn Lock | facebook/jest |
| `--pip` | PIP | psf/requests |
| `--poetry` | Poetry Lock | python-poetry/poetry |
| `--pipenv` | Pipenv CLI | pypa/pipenv |
| `--uv` | UV Lock | astral-sh/ruff |
| `--conda` | Conda CLI | Anaconda-Platform/anaconda-client |
| `--maven` | Maven CLI | spring-projects/spring-petclinic |
| `--gradle` | Gradle Native Inspector | square/okhttp |
| `--sbt` | Sbt Native Inspector | scala/scala-parser-combinators |
| `--go` | GoMod CLI | cli/cli |
| `--cargo` | Cargo CLI | sharkdp/bat |
| `--nuget` | NuGet Solution Native Inspector | dotnet-architecture/eShopOnWeb |
| `--gemfile` | Gemfile Lock | sinatra/sinatra |
| `--composer` | Composer Lock | laravel/laravel |
| `--conan` | Conan CLI / Lock | conan-io/examples |
| `--dart` | Dart PubSpec Lock | dart-lang/pub |
| `--bazel` | Bazel CLI | abseil/abseil-cpp |
| `--erlang` | Erlang Rebar CLI | ninenines/cowboy |
| `--ocaml` | OCaml Opam CLI | mirage/mirage |
| `--perl` | Perl CPAN CLI | libwww-perl/libwww-perl |
| `--r` | R Packrat Lock | rstudio/shiny |

See `scan_targets/<pm>/README.md` for each PM's pre-scan steps and rationale.

## Notes

- **conda**: requires `conda env create` before the Conda CLI detector fires. See `scan_targets/conda/README.md`.
- **Swift**: commented out in the Dockerfile (~2 GB layer). Uncomment `ARG SWIFT_VERSION` block to enable.
- **Bitbake/Yocto**: not included (impractical in a general container). See `scan_targets/bitbake/README.md`.
- **CocoaPods**: macOS/iOS only, not included.
