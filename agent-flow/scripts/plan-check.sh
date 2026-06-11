#!/usr/bin/env bash
set -euo pipefail

change_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: plan-check.sh --change-dir <change-dir>"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ] || [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/_common.sh"

extract_plan_audit() {
  awk '
    BEGIN { in_section=0 }
    /^[[:space:]]*##[[:space:]]+Plan Audit[[:space:]]*$/ { in_section=1; next }
    /^[[:space:]]*##[[:space:]]+/ && in_section { exit }
    in_section { print }
  ' "$1"
}

flow="$(flow_level "$change_dir")"
if [ "$flow" != "Heavy" ]; then
  echo "SKIP: plan-check is only required for Heavy changes."
  exit 0
fi

plan="$change_dir/PLAN.md"
audit="$change_dir/AUDIT.md"
[ -f "$plan" ] || { echo "PLAN.md not found in $change_dir" >&2; exit 1; }
[ -f "$audit" ] || { echo "AUDIT.md not found in $change_dir" >&2; exit 1; }

issues=()

while IFS= read -r key; do
  key="$(printf '%s' "$key" | xargs)"
  [ -n "$key" ] || continue
  if ! grep -Fq "$key" "$plan"; then
    issues+=("PLAN.md missing required key or section: $key")
  fi
done < <(get_rule_list "plan-required.keys")

if grep -Eiq '\{.+\}|TODO|TBD' "$plan"; then
  issues+=("PLAN.md still contains placeholders.")
fi

plan_status="$(awk '
  BEGIN { IGNORECASE = 1 }
  /^[[:space:]]*>?[[:space:]]*Plan Status:[[:space:]]*/ {
    value=$0
    sub(/^.*Plan Status:[[:space:]]*/, "", value)
    sub(/[[:space:]].*$/, "", value)
    print tolower(value)
    exit
  }
' "$plan")"
case "$plan_status" in
  planned|in-progress|completed|superseded|deferred) ;;
  "") issues+=("PLAN.md missing Plan Status.") ;;
  *) issues+=("Plan Status must be planned/in-progress/completed/superseded/deferred before Plan Audit passes.") ;;
esac

plan_audit="$(extract_plan_audit "$audit")"
if ! meaningful "$plan_audit" true 'TODO|TBD|\{.+\}|not run'; then
  issues+=("AUDIT.md missing meaningful Plan Audit section.")
else
  if ! printf '%s\n' "$plan_audit" | grep -Eiq '^[[:space:]]*Verdict:[[:space:]]*(accept|conditional)[[:space:]]*$'; then
    issues+=("Plan Audit verdict must be accept or conditional.")
  fi
  for field in Reviewer Date; do
    value="$(printf '%s\n' "$plan_audit" | awk -F':' -v f="$field" 'tolower($1) ~ "^[[:space:]]*" tolower(f) "$" { sub(/^[^:]+:[[:space:]]*/, "", $0); print; exit }')"
    if ! meaningful "$value" true 'TODO|TBD|\{.+\}|not run'; then
      issues+=("Plan Audit missing meaningful $field.")
    fi
  done

  while IFS= read -r item; do
    item="$(printf '%s' "$item" | xargs)"
    [ -n "$item" ] || continue
    if ! printf '%s\n' "$plan_audit" | grep -Fq -- "- [x] $item"; then
      issues+=("Plan Audit checklist item is not checked: $item")
    fi
  done < <(get_rule_list "plan-audit.keys")

  if printf '%s\n' "$plan_audit" | grep -Eq '^[[:space:]]*-[[:space:]]+\[[[:space:]]\][[:space:]]+'; then
    issues+=("Plan Audit still has unchecked checklist items.")
  fi
  if printf '%s\n' "$plan_audit" | grep -Eiq '^[[:space:]]*Verdict:[[:space:]]*conditional[[:space:]]*$'; then
    findings="$(printf '%s\n' "$plan_audit" | awk 'BEGIN{f=0} /^Findings:[[:space:]]*$/{f=1;next} f{print}')"
    if ! meaningful "$findings" true 'TODO|TBD|\{.+\}|not run'; then
      issues+=("Conditional Plan Audit must include findings and residual risk.")
    fi
  fi
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "plan-check failed:" >&2
  for issue in "${issues[@]}"; do echo " - $issue" >&2; done
  exit 2
fi

echo "plan-check passed."
