#!/usr/bin/env bash
set -euo pipefail

change_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: coverage-check.sh --change-dir <change-dir>"
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

requirement="$change_dir/REQUIREMENT.md"
verify="$change_dir/VERIFY.md"
issues=()

if [ ! -f "$requirement" ]; then
  echo "Coverage check failed:"
  echo " - REQUIREMENT.md not found in $change_dir"
  exit 2
fi
if [ ! -f "$verify" ]; then
  echo "Coverage check failed:"
  echo " - VERIFY.md not found in $change_dir"
  exit 2
fi

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

meaningful() {
  local value
  value="$(trim "$1")"
  [ -n "$value" ] || return 1
  ! printf '%s' "$value" | grep -Eiq '^(TODO|TBD|pending|\{.+\}|path/to|example)$'
}

mapfile -t acs < <(
  grep -Eoh 'AC[-_ ]?[0-9]{2,4}' "$requirement" \
    | tr '[:lower:]' '[:upper:]' \
    | sed -E 's/[ _]/-/g' \
    | sort -u
)

if [ "${#acs[@]}" -eq 0 ]; then
  issues+=("No AC ids found in REQUIREMENT.md.")
fi

declare -A evidence_result=()
declare -A evidence_location=()

while IFS= read -r line; do
  line="${line%$'\r'}"
  printf '%s\n' "$line" | grep -qE '^[[:space:]]*\|' || continue
  row="${line#|}"
  row="${row%|}"
  IFS='|' read -r ac_cell _summary _type location result _risk _rest <<< "$row"
  ac_cell="$(trim "${ac_cell:-}")"
  if printf '%s' "$ac_cell" | grep -Eiq '^(AC|-+)$'; then
    continue
  fi
  ac="$(printf '%s\n' "$ac_cell" | grep -Eoi 'AC[-_ ]?[0-9]{2,4}' | head -n 1 | tr '[:lower:]' '[:upper:]' | sed -E 's/[ _]/-/g' || true)"
  [ -n "$ac" ] || continue
  evidence_result["$ac"]="$(trim "${result:-}" | tr '[:upper:]' '[:lower:]')"
  evidence_location["$ac"]="$(trim "${location:-}")"
done < <(
  awk '
    /^##[[:space:]]+AC Evidence[[:space:]]*$/ { in_section = 1; next }
    in_section && /^##[[:space:]]+/ { in_section = 0 }
    in_section { print }
  ' "$verify"
)

covered=0
for ac in "${acs[@]}"; do
  if [ -z "${evidence_result["$ac"]+x}" ]; then
    issues+=("Missing AC Evidence row for $ac.")
    continue
  fi
  case "${evidence_result["$ac"]}" in
    pass|conditional|skipped) ;;
    *)
      issues+=("$ac evidence result must be pass, conditional, or skipped for coverage.")
      continue ;;
  esac
  if ! meaningful "${evidence_location["$ac"]:-}"; then
    issues+=("$ac evidence must include Evidence Location.")
    continue
  fi
  covered=$((covered + 1))
done

coverage_percent="0"
if [ "${#acs[@]}" -gt 0 ]; then
  coverage_percent="$(awk -v covered="$covered" -v total="${#acs[@]}" 'BEGIN { printf "%.2f", (covered / total) * 100 }')"
fi

coverage_rows=0
test_coverage_found=false
test_coverage_issue=false
while IFS= read -r line; do
  line="${line%$'\r'}"
  printf '%s\n' "$line" | grep -qE '^[[:space:]]*\|' || continue
  row="${line#|}"
  row="${row%|}"
  IFS='|' read -r metric source value result notes _rest <<< "$row"
  metric="$(trim "${metric:-}")"
  if printf '%s' "$metric" | grep -Eiq '^(Metric|-+)$'; then
    continue
  fi
  coverage_rows=$((coverage_rows + 1))
  result="$(trim "${result:-}" | tr '[:upper:]' '[:lower:]')"
  source="$(trim "${source:-}")"
  notes="$(trim "${notes:-}")"
  if printf '%s' "$metric" | grep -Eiq 'test coverage|automated coverage|coverage' &&
     ! printf '%s' "$metric" | grep -Eiq '^AC Coverage$'; then
    test_coverage_found=true
    case "$result" in
      pass|conditional|skipped) ;;
      *) issues+=("Test Coverage result must be pass, conditional, or skipped."); test_coverage_issue=true ;;
    esac
    if { [ "$result" = "conditional" ] || [ "$result" = "skipped" ]; } && ! meaningful "$notes"; then
      issues+=("Skipped or conditional Test Coverage must include Notes explaining why.")
      test_coverage_issue=true
    fi
    if ! meaningful "$source"; then
      issues+=("Test Coverage row must include Source.")
      test_coverage_issue=true
    fi
  fi
done < <(
  awk '
    /^##[[:space:]]+Coverage Summary[[:space:]]*$/ { in_section = 1; next }
    in_section && /^##[[:space:]]+/ { in_section = 0 }
    in_section { print }
  ' "$verify"
)

if [ "$coverage_rows" -eq 0 ]; then
  issues+=("VERIFY.md must include a Coverage Summary table.")
elif [ "$test_coverage_found" = false ] && [ "$test_coverage_issue" = false ]; then
  issues+=("Coverage Summary must include a Test Coverage row.")
fi

echo "AC coverage: $covered/${#acs[@]} ($coverage_percent%)"

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Coverage check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Coverage check passed."
