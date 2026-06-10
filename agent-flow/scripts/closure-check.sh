#!/usr/bin/env bash
set -euo pipefail

change_dir=""
project_root="."

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: closure-check.sh --change-dir <change-dir> [--project-root <path>]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
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
project_root="$(cd "$project_root" 2>/dev/null && pwd || echo "$project_root")"

meaningful_file() {
  [ -f "$1" ] && [ -s "$1" ]
}

flow="Unknown"
if [ -f "$change_dir/CHANGE.md" ]; then
  if grep -Eiq '\[x\][[:space:]]+Heavy' "$change_dir/CHANGE.md"; then flow="Heavy"
  elif grep -Eiq '\[x\][[:space:]]+Standard' "$change_dir/CHANGE.md"; then flow="Standard"
  elif grep -Eiq '\[x\][[:space:]]+Light' "$change_dir/CHANGE.md"; then flow="Light"
  fi
fi

issues=()
for file in CHANGE.md CODE_SCAN.md VERIFY.md REPORT.md; do
  meaningful_file "$change_dir/$file" || issues+=("Missing or empty required closure file: $file")
done

if [ "$flow" = "Standard" ] || [ "$flow" = "Heavy" ]; then
  for file in REQUIREMENT.md DESIGN.md TASKS.md EVOLUTION.md; do
    meaningful_file "$change_dir/$file" || issues+=("Missing or empty Standard/Heavy closure file: $file")
  done
fi

if [ "$flow" = "Heavy" ]; then
  for file in PLAN.md REVIEW.md AUDIT.md; do
    meaningful_file "$change_dir/$file" || issues+=("Missing or empty Heavy closure file: $file")
  done
  verdict="$(awk '
    /^##[[:space:]]+Closure Audit/ { in_section = 1; next }
    in_section && /^##[[:space:]]+/ { in_section = 0 }
    in_section && /Verdict:/ {
      value = $0
      sub(/^.*Verdict:[[:space:]]*/, "", value)
      sub(/[[:space:]].*$/, "", value)
      print tolower(value)
      exit
    }
  ' "$change_dir/AUDIT.md" 2>/dev/null || true)"
  case "$verdict" in
    acceptable|accept|conditional) ;;
    *) issues+=("Closure Audit verdict must be acceptable, accept, or conditional.") ;;
  esac
fi

verify_text="$(cat "$change_dir/VERIFY.md" 2>/dev/null || true)"
audit_text="$(cat "$change_dir/AUDIT.md" 2>/dev/null || true)"
report_text="$(cat "$change_dir/REPORT.md" 2>/dev/null || true)"

if ! printf '%s' "$verify_text" | grep -q "AC Evidence"; then
  issues+=("VERIFY.md must include AC Evidence.")
fi

if [ "$flow" = "Heavy" ]; then
  combined="$verify_text"$'\n'"$audit_text"
  for gate in ac-check code-drift-check blocked-check task-boundary-check; do
    if ! printf '%s' "$combined" | grep -qF "$gate"; then
      issues+=("Heavy closure must mention gate result: $gate")
    fi
  done
  if printf '%s' "$audit_text" | grep -Eiq 'Verdict:[[:space:]]*conditional' &&
     ! printf '%s\n%s\n%s' "$verify_text" "$audit_text" "$report_text" | grep -Eiq 'residual risk|残余风险|剩余风险'; then
    issues+=("Conditional closure must document residual risk.")
  fi
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Closure check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Closure check passed for $flow change."
