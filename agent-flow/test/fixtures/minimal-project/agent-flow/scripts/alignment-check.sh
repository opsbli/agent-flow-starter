#!/usr/bin/env bash
set -euo pipefail

change_dir=""

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
    -h|--help)
      cat <<'EOF'
Usage: agent-flow/scripts/alignment-check.sh --change-dir <change-dir>

Checks that Standard / Heavy changes have Design Alignment completed before
planning, task creation, or implementation.
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
  exit 1
fi

flow_level() {
  local file="$1/CHANGE.md"
  if [ ! -f "$file" ]; then
    echo "Unknown"
  elif grep -Eiq '\[x\][[:space:]]+Heavy' "$file"; then
    echo "Heavy"
  elif grep -Eiq '\[x\][[:space:]]+Standard' "$file"; then
    echo "Standard"
  elif grep -Eiq '\[x\][[:space:]]+Light' "$file"; then
    echo "Light"
  else
    echo "Unknown"
  fi
}

alignment_verdict() {
  local file="$1"
  [ -f "$file" ] || return 0
  awk '
    BEGIN { IGNORECASE = 1 }
    /^[[:space:]]*Alignment Verdict:[[:space:]]*/ {
      value = $0
      sub(/^.*Alignment Verdict:[[:space:]]*/, "", value)
      sub(/[[:space:]].*$/, "", value)
      print tolower(value)
      exit
    }
  ' "$file"
}

flow="$(flow_level "$change_dir")"
if [ "$flow" = "Light" ]; then
  echo "Alignment check skipped: Light change."
  exit 0
fi

if [ "$flow" = "Unknown" ]; then
  echo "Cannot determine flow level from CHANGE.md. Mark one of Light / Standard / Heavy." >&2
  exit 1
fi

design="$change_dir/DESIGN.md"
if [ ! -f "$design" ]; then
  echo "DESIGN.md not found in $change_dir" >&2
  exit 1
fi

verdict="$(alignment_verdict "$design")"
if [ "$verdict" = "aligned" ]; then
  echo "Alignment check passed: Alignment Verdict is aligned."
  exit 0
fi

if [ "$verdict" = "skipped" ]; then
  if grep -Eiq '^[[:space:]]*Skip Reason:[[:space:]]*\S' "$design"; then
    echo "Alignment check passed: Alignment Verdict is skipped with reason."
    exit 0
  fi
  echo "Alignment Verdict is skipped, but Skip Reason is missing." >&2
  exit 2
fi

if [ -z "$verdict" ]; then
  echo "Alignment Verdict missing in DESIGN.md." >&2
else
  echo "Alignment Verdict is not accepted: $verdict" >&2
fi
echo "Use 'Alignment Verdict: aligned' or 'Alignment Verdict: skipped' with 'Skip Reason: ...'." >&2
exit 2
