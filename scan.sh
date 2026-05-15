#!/usr/bin/env bash
set -euo pipefail

if ((BASH_VERSINFO[0] < 4)); then
  echo "ERROR: scan.sh requires bash 4.0 or newer (found ${BASH_VERSION})" >&2
  exit 1
fi

DETECT_VERSION="11.4.2"
DETECT_JAR="/opt/blackduck/detect-${DETECT_VERSION}.jar"
BLACKDUCK_URL="${BLACKDUCK_URL:-}"
BLACKDUCK_API_TOKEN="${BLACKDUCK_API_TOKEN:-}"
TRUST_CERT=false
declare -a PMS_TO_RUN=()

declare -A PM_PATHS=(
  [npm]="/opt/scan_targets/npm/express"
  [pnpm]="/opt/scan_targets/pnpm/vite"
  [yarn]="/opt/scan_targets/yarn/jest"
  [pip]="/opt/scan_targets/pip/requests"
  [poetry]="/opt/scan_targets/poetry/poetry"
  [pipenv]="/opt/scan_targets/pipenv/pipenv"
  [uv]="/opt/scan_targets/uv/uv"
  [conda]="/opt/scan_targets/conda/anaconda-client"
  [maven]="/opt/scan_targets/maven/spring-petclinic"
  [gradle]="/opt/scan_targets/gradle/okhttp"
  [sbt]="/opt/scan_targets/sbt/scala-parser-combinators"
  [go]="/opt/scan_targets/go/cli"
  [cargo]="/opt/scan_targets/cargo/bat"
  [nuget]="/opt/scan_targets/nuget/eShopOnWeb"
  [gemfile]="/opt/scan_targets/gemfile/sinatra"
  [composer]="/opt/scan_targets/composer/laravel"
  [conan]="/opt/scan_targets/conan/examples"
  [dart]="/opt/scan_targets/dart/pub"
  [bazel]="/opt/scan_targets/bazel/abseil-cpp"
  [erlang]="/opt/scan_targets/erlang/cowboy"
  [ocaml]="/opt/scan_targets/ocaml/mirage"
  [perl]="/opt/scan_targets/perl/libwww-perl"
  [r]="/opt/scan_targets/r/shiny"
)

ALL_PMS=(npm pnpm yarn pip poetry pipenv uv conda maven gradle sbt go cargo nuget gemfile composer conan dart bazel erlang ocaml perl r)

usage() {
  cat <<'EOF'
Usage: scan.sh [OPTIONS] [--pm <name> | --<pm-name> ...]

Environment:
  BLACKDUCK_URL          Black Duck server URL
  BLACKDUCK_API_TOKEN    API token

Options:
  --url <url>            Override BLACKDUCK_URL
  --token <token>        Override BLACKDUCK_API_TOKEN
  --all                  Scan all 23 package managers sequentially
  --pm <name>            Scan a specific PM (e.g. --pm npm)
  --<pm>                 Shortcut for --pm <pm> (e.g. --npm, --maven)
  --trust-cert           Pass --blackduck.trust.cert=true to Detect
  --detect-version <v>   Override Detect version (default: 11.4.2)
  -h, --help             Show this help

Package managers:
  npm pnpm yarn pip poetry pipenv uv conda maven gradle sbt go cargo
  nuget gemfile composer conan dart bazel erlang ocaml perl r
EOF
}

run_scan() {
  local pm="$1"
  if [[ -z "${PM_PATHS[$pm]+_}" ]]; then
    echo "ERROR: unknown package manager: $pm" >&2
    echo "Valid PMs: ${ALL_PMS[*]}" >&2
    return 1
  fi
  local path="${PM_PATHS[$pm]}"
  local project_name="${pm}-detect-${DETECT_VERSION}-test"
  echo "==> Scanning $pm at $path (project: $project_name)"
  local -a args=(
    java -jar "${DETECT_JAR}"
    "--detect.project.name=${project_name}"
    "--detect.source.path=${path}"
    "--detect.tools=DETECTOR"
    "--detect.detector.search.depth=2"
    "--detect.detector.search.continue=true"
  )
  if [[ "$TRUST_CERT" == true ]]; then
    args+=("--blackduck.trust.cert=true")
  fi
  "${args[@]}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --url)
      [[ $# -ge 2 ]] || { echo "ERROR: --url requires a value" >&2; usage >&2; exit 1; }
      BLACKDUCK_URL="$2"; shift 2 ;;
    --token)
      [[ $# -ge 2 ]] || { echo "ERROR: --token requires a value" >&2; usage >&2; exit 1; }
      BLACKDUCK_API_TOKEN="$2"; shift 2 ;;
    --detect-version)
      [[ $# -ge 2 ]] || { echo "ERROR: --detect-version requires a value" >&2; usage >&2; exit 1; }
      DETECT_VERSION="$2"
      DETECT_JAR="/opt/blackduck/detect-${DETECT_VERSION}.jar"
      shift 2 ;;
    --trust-cert)
      TRUST_CERT=true; shift ;;
    --all)
      PMS_TO_RUN=("${ALL_PMS[@]}"); shift ;;
    --pm)
      [[ $# -ge 2 ]] || { echo "ERROR: --pm requires a value" >&2; usage >&2; exit 1; }
      [[ -n "${PM_PATHS[$2]+_}" ]] || { echo "ERROR: unknown package manager: $2" >&2; echo "Valid PMs: ${ALL_PMS[*]}" >&2; exit 1; }
      PMS_TO_RUN+=("$2"); shift 2 ;;
    --*)
      pm="${1#--}"
      if [[ -n "${PM_PATHS[$pm]+_}" ]]; then
        PMS_TO_RUN+=("$pm"); shift
      else
        echo "ERROR: unknown option: $1" >&2
        usage >&2
        exit 1
      fi
      ;;
    *)
      echo "ERROR: unexpected argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ ${#PMS_TO_RUN[@]} -eq 0 ]]; then
  echo "ERROR: no package managers specified. Use --all or --pm <name>." >&2
  usage >&2
  exit 1
fi

if [[ -z "$BLACKDUCK_URL" ]]; then
  echo "ERROR: BLACKDUCK_URL is not set. Use --url or set the environment variable." >&2
  exit 1
fi

if [[ -z "$BLACKDUCK_API_TOKEN" ]]; then
  echo "ERROR: BLACKDUCK_API_TOKEN is not set. Use --token or set the environment variable." >&2
  exit 1
fi

if [[ ! -f "$DETECT_JAR" ]]; then
  echo "ERROR: $DETECT_JAR not found. Only detect-${DETECT_VERSION}.jar is baked into this image." >&2
  exit 1
fi

failed_pms=()
for pm in "${PMS_TO_RUN[@]}"; do
  run_scan "$pm" || { echo "WARNING: scan for $pm failed, continuing..." >&2; failed_pms+=("$pm"); }
done

if [[ ${#failed_pms[@]} -gt 0 ]]; then
  echo "ERROR: the following scans failed: ${failed_pms[*]}" >&2
  exit 1
fi
