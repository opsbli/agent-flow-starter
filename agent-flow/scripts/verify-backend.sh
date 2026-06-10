#!/usr/bin/env bash
set -euo pipefail

skip_tests=false

for arg in "$@"; do
  case "$arg" in
    --skip-tests|-SkipTests)
      skip_tests=true
      ;;
    -h|--help)
      cat <<'EOF'
Usage: agent-flow/scripts/verify-backend.sh [--skip-tests]

Runs the backend Maven baseline verification.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$skip_tests" = false ]; then
  bash "$script_dir/run-verify.sh" --name backend_compile
  bash "$script_dir/run-verify.sh" --name backend_test
else
  bash "$script_dir/run-verify.sh" --name backend_compile
fi
