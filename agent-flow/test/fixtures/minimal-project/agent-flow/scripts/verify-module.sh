#!/usr/bin/env bash
# DEPRECATED: Use run-verify.sh directly:
#   bash agent-flow/scripts/run-verify.sh --name module_compile --module <name>
#   bash agent-flow/scripts/run-verify.sh --name module_test --module <name>
set -euo pipefail

echo "[DEPRECATED] Use run-verify.sh --name module_compile|module_test --module <name> instead" >&2

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
DEPRECATED: Use run-verify.sh --name module_compile|module_test --module <name>
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
