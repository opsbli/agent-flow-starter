#!/usr/bin/env bash
set -euo pipefail

change_dir=""
expected_stage=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      change_dir="$2"
      shift 2
      ;;
    --expected-stage|-ExpectedStage)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      expected_stage="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: agent-flow/scripts/state-check.sh --change-dir <change-dir> [--expected-stage <stage>]

Checks that STATE.md current_stage matches the stage inferred by next-step.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$change_dir" ]; then
  echo "Missing required argument: --change-dir" >&2
  exit 2
fi

if [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi

if [ ! -f "$change_dir/STATE.md" ]; then
  echo "STATE.md not found in $change_dir" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
next_step="$script_dir/next-step.sh"
if [ ! -f "$next_step" ]; then
  echo "next-step.sh not found next to state-check.sh" >&2
  exit 1
fi

output="$(bash "$next_step" --change-dir "$change_dir")"
inferred_stage="$(printf '%s\n' "$output" | sed -n 's/^[[:space:]]*"stage": "\([^"]*\)",\{0,1\}$/\1/p' | head -n 1)"
state_stage="$(printf '%s\n' "$output" | sed -n 's/^[[:space:]]*"state_current_stage": "\([^"]*\)",\{0,1\}$/\1/p' | head -n 1)"

if [ -z "$state_stage" ]; then
  echo "STATE.md is missing current_stage." >&2
  exit 2
fi

if [ -n "$expected_stage" ] && [ "$inferred_stage" != "$expected_stage" ]; then
  echo "Expected inferred stage '$expected_stage', got '$inferred_stage'." >&2
  exit 2
fi

if [ "$state_stage" != "$inferred_stage" ]; then
  echo "STATE.md is out of sync." >&2
  echo " - current_stage: $state_stage" >&2
  echo " - next-step stage: $inferred_stage" >&2
  echo "Update STATE.md after reading next-step output." >&2
  exit 2
fi

echo "State check passed: STATE.md current_stage matches next-step stage '$inferred_stage'."
