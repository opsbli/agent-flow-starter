#!/usr/bin/env bash
# Run verification commands from manifest.yaml
#
# NOTE: verify-backend.sh and verify-module.sh are deprecated.
# Use this script directly:
#   bash run-verify.sh --name backend_compile
#   bash run-verify.sh --name backend_test
#   bash run-verify.sh --name module_compile --module <name>
#   bash run-verify.sh --all
set -euo pipefail

name=""
all=false
module=""
manifest="agent-flow/manifest.yaml"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name|-Name)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      name="$2"
      shift 2
      ;;
    --all|-All)
      all=true
      shift
      ;;
    --module|-Module)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      module="$2"
      shift 2
      ;;
    --manifest|-Manifest)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      manifest="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: agent-flow/scripts/run-verify.sh --name <verification-key> [--module <module>]
       agent-flow/scripts/run-verify.sh --all [--module <module>]

Runs verification commands from agent-flow/manifest.yaml.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [ "$all" = false ] && [ -z "$name" ]; then
  echo "Use --name <verification-key> or --all." >&2
  exit 2
fi

if [ ! -f "$manifest" ]; then
  echo "Manifest not found: $manifest" >&2
  exit 1
fi

get_command() {
  local key="$1"
  local command
  command="$(sed -nE "s/^[[:space:]]+$key:[[:space:]]*(.*)$/\1/p" "$manifest" | head -n 1)"
  if [ "${#command}" -ge 2 ]; then
    first="${command:0:1}"
    last="${command: -1}"
    if { [ "$first" = '"' ] && [ "$last" = '"' ]; } || { [ "$first" = "'" ] && [ "$last" = "'" ]; }; then
      command="${command:1:${#command}-2}"
    fi
  fi

  if [ -z "$command" ]; then
    return 1
  fi
  case "$command" in
    TODO_*|N/A|NONE|none|null)
      return 1
      ;;
  esac
  printf '%s' "$command"
}

run_key() {
  local key="$1"
  local command

  if ! command="$(get_command "$key")"; then
    echo "Skipping $key: no runnable command in $manifest"
    return 0
  fi

  if [[ "$command" == *"{module}"* ]]; then
    if [ -z "$module" ]; then
      echo "Skipping $key: command requires --module"
      return 0
    fi
    command="${command//\{module\}/$module}"
  fi

  echo "Running $key: $command"
  sh -c "$command"
}

if [ "$all" = true ]; then
  for key in backend_compile backend_test module_compile module_test frontend_typecheck frontend_test frontend_lint; do
    run_key "$key"
  done
else
  run_key "$name"
fi
