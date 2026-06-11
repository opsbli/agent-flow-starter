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

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/_common.sh"
project_root="$(cd "$project_root" 2>/dev/null && pwd || echo "$project_root")"
flow="$(flow_level "$change_dir")"

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
  printf '%s' "$verify_text" | grep -q "Machine Gate Summary" || issues+=("VERIFY.md must include Machine Gate Summary.")
  for column in Command "Exit Code" When Evidence; do
    printf '%s' "$verify_text" | grep -qF "$column" || issues+=("Machine Gate Summary must include column: $column")
  done

  while IFS= read -r gate; do
    [ -n "$gate" ] || continue
    row="$(printf '%s\n' "$verify_text" | awk -F'|' -v gate="$gate" '
      {
        first=$2
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", first)
        if (first == gate) { print; exit }
      }
    ')"
    if [ -z "$row" ]; then
      issues+=("Heavy closure Machine Gate Summary missing gate row: $gate")
      continue
    fi
    IFS='|' read -r _ gate_cell required_for result command exit_code when evidence _extra <<< "$row"
    result="$(printf '%s' "$result" | xargs | tr '[:upper:]' '[:lower:]')"
    command="$(printf '%s' "$command" | xargs)"
    exit_code="$(printf '%s' "$exit_code" | xargs)"
    when="$(printf '%s' "$when" | xargs)"
    evidence="$(printf '%s' "$evidence" | xargs)"
    case "$result" in
      pass|skipped|conditional) ;;
      *) issues+=("$gate result must be pass, skipped, or conditional for closure.") ;;
    esac
    if [ "$result" = "pass" ] && [ "$exit_code" != "0" ]; then
      issues+=("$gate pass row must record Exit Code 0.")
    fi
    meaningful "$command" true 'TODO|TBD|\{.+\}' || issues+=("$gate row must record the command that was run.")
    meaningful "$when" true 'TODO|TBD|\{.+\}' || issues+=("$gate row must record when it was run or decided.")
    meaningful "$evidence" true 'TODO|TBD|\{.+\}' || issues+=("$gate row must record evidence or a skip reason.")
  done < <(get_rule_list closure-heavy-gates.keys)

  if printf '%s' "$audit_text" | grep -Eiq 'Verdict:[[:space:]]*conditional' &&
     ! printf '%s\n%s\n%s' "$verify_text" "$audit_text" "$report_text" | grep -Eiq 'residual risk|remaining risk|known risk|风险'; then
    issues+=("Conditional closure must document residual risk.")
  fi
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Closure check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Closure check passed for $flow change."
