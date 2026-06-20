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

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/_common.sh"

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

alignment_section() {
  awk '
    BEGIN { in_section = 0 }
    /^[[:space:]]*##[[:space:]]+Design Alignment \/ Grill[[:space:]]*$/ { in_section = 1; next }
    /^[[:space:]]*##[[:space:]]+/ && in_section { exit }
    in_section { print }
  ' "$1"
}

flow="$(flow_level "$change_dir")"
if [ "$flow" = "Light" ] || [ "$flow" = "Emergency" ]; then
  echo "SKIP: alignment-check is not required for $flow changes."
  exit 0
fi

if [ "$flow" = "Unknown" ]; then
  echo "Cannot determine flow level from CHANGE.md. Mark one of Light / Standard / Heavy / Emergency." >&2
  exit 1
fi

design="$change_dir/DESIGN.md"
if [ ! -f "$design" ]; then
  echo "DESIGN.md not found in $change_dir" >&2
  exit 1
fi

verdict="$(alignment_verdict "$design")"
section="$(alignment_section "$design")"
issues=()

if [ -z "$(printf '%s' "$section" | xargs)" ]; then
  issues+=("DESIGN.md missing 'Design Alignment / Grill' section.")
fi

if [ "$verdict" = "skipped" ]; then
  if grep -Eiq '^[[:space:]]*Skip Reason:[[:space:]]*\S' "$design"; then
    echo "alignment-check passed: skipped with explicit reason."
    exit 0
  fi
  echo "Alignment Verdict is skipped, but Skip Reason is missing." >&2
  exit 2
fi

if [ "$verdict" != "aligned" ]; then
  if [ -z "$verdict" ]; then
    issues+=("Alignment Verdict missing in DESIGN.md.")
  else
    issues+=("Alignment Verdict is not accepted: $verdict")
  fi
fi

if [ "$verdict" = "aligned" ]; then
  if ! printf '%s\n' "$section" | grep -Eiq '^[[:space:]]*Alignment Source:[[:space:]]*(code-confirmed|user-confirmed|mixed)[[:space:]]*$'; then
    issues+=("Alignment Source must be code-confirmed, user-confirmed, or mixed.")
  fi
  if ! printf '%s\n' "$section" | grep -Eiq '^[[:space:]]*Open Questions:[[:space:]]*none[[:space:]]*$'; then
    issues+=("Open Questions must be 'none' before Alignment Verdict is aligned.")
  fi

  # Detect extra columns in the alignment table (common pitfall)
  header="$(printf '%s\n' "$section" | grep -E '^\|.*#.*\|.*Question.*\|' | head -n 1 || true)"
  if [ -n "$header" ]; then
    col_count=$(printf '%s\n' "$header" | awk -F'|' '{print NF-2}')
    if [ "$col_count" -gt 4 ] 2>/dev/null; then
      issues+=("Design Alignment table has $col_count data columns (expected exactly 4: | # | Question | Confirmation | Evidence |). Extra column causes field-offset errors — remove any additional column like 'Recommendation'.")
    fi
  fi

  user_confirmed_count=0
  while IFS= read -r question; do
    question="$(printf '%s' "$question" | xargs)"
    [ -n "$question" ] || continue
    line="$(printf '%s\n' "$section" | grep -F "| $question |" | head -n 1 || true)"
    if [ -z "$line" ]; then
      issues+=("Missing alignment question row: $question")
      continue
    fi

    confirmation="$(
      printf '%s\n' "$line" |
        awk -F'|' '{ value=$4; gsub(/^[[:space:]]+|[[:space:]]+$/, "", value); print tolower(value) }'
    )"
    if [ "$confirmation" = "user-confirmed" ]; then
      user_confirmed_count=$((user_confirmed_count + 1))
    elif [ "$confirmation" != "code-confirmed" ]; then
      issues+=("Alignment question confirmation must be user-confirmed or code-confirmed: $question")
    fi
  done < <(get_rule_list "design-alignment.questions")

  if [ "$user_confirmed_count" -lt 3 ]; then
    issues+=("Alignment requires at least 3 user-confirmed questions; found $user_confirmed_count.")
  fi
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "alignment-check failed:" >&2
  for issue in "${issues[@]}"; do echo " - $issue" >&2; done
  echo "Use 'Alignment Verdict: aligned' after at least 3 required questions are user-confirmed, or 'Alignment Verdict: skipped' with Skip Reason." >&2
  exit 2
fi

echo "alignment-check passed."
