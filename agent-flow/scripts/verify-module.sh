#!/usr/bin/env bash
set -euo pipefail

module=""
skip_tests=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --module|-Module)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      module="$2"
      shift 2
      ;;
    --skip-tests|-SkipTests)
      skip_tests=true
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage: agent-flow/scripts/verify-module.sh --module <maven-module> [--skip-tests]

Runs Maven verification for one module with -am.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$module" ]; then
  echo "Missing required argument: --module" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$skip_tests" = false ]; then
  bash "$script_dir/run-verify.sh" --name module_compile --module "$module"
  bash "$script_dir/run-verify.sh" --name module_test --module "$module"
else
  bash "$script_dir/run-verify.sh" --name module_compile --module "$module"
fi
