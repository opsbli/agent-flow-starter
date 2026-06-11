#!/usr/bin/env bash
set -euo pipefail

change_dir=""
test_root="."

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
    --test-root|-TestRoot)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      test_root="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: agent-flow/scripts/ac-check.sh --change-dir <change-dir> [--test-root <path>]

Checks that REQUIREMENT.md contains machine-readable AC ids and that each id
has a complete row in VERIFY.md's AC Evidence table.
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

requirement="$change_dir/REQUIREMENT.md"
if [ ! -f "$requirement" ]; then
  echo "REQUIREMENT.md not found in $change_dir" >&2
  exit 1
fi

normalize_ac() {
  local value="$1"
  printf '%s\n' "$value" \
    | grep -Eoi 'AC[-_ ]?[0-9]{2,4}' \
    | head -n 1 \
    | tr '[:lower:]' '[:upper:]' \
    | sed -E 's/[ _]/-/g'
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

meaningful() {
  local value
  value="$(trim "$1")"
  local allow_none="${2:-false}"
  if [ -z "$value" ]; then return 1; fi
  if printf '%s' "$value" | grep -Eiq '^(TODO|TBD|pending|\{.+\}|path/to|example)$'; then return 1; fi
  if [ "$allow_none" != true ] && printf '%s' "$value" | grep -Eiq '^(none|n/a|na|null)$'; then return 1; fi
  return 0
}

mapfile -t acs < <(
  grep -Eoh 'AC[-_ ]?[0-9]{2,4}' "$requirement" \
    | tr '[:lower:]' '[:upper:]' \
    | sed -E 's/[ _]/-/g' \
    | sort -u
)

if [ "${#acs[@]}" -eq 0 ]; then
  echo "No AC ids found in $requirement" >&2
  exit 1
fi

verify="$change_dir/VERIFY.md"
if [ ! -f "$verify" ]; then
  echo "AC check failed:"
  echo " - VERIFY.md not found in $change_dir"
  exit 2
fi

declare -A requirement_summary_by_ac=()
declare -A evidence_type_by_ac=()
declare -A evidence_location_by_ac=()
declare -A result_by_ac=()
declare -A residual_risk_by_ac=()
declare -A row_count_by_ac=()

while IFS= read -r line; do
  line="${line%$'\r'}"
  if ! printf '%s\n' "$line" | grep -qE '^[[:space:]]*\|'; then
    continue
  fi
  row="${line#|}"
  row="${row%|}"
  IFS='|' read -r ac_cell summary_cell type_cell location_cell result_cell risk_cell _rest <<< "$row"
  ac_cell="$(trim "$ac_cell")"
  if printf '%s' "$ac_cell" | grep -Eiq '^(AC|-+)$'; then
    continue
  fi
  ac="$(normalize_ac "$ac_cell" || true)"
  if [ -z "$ac" ]; then
    continue
  fi
  row_count_by_ac["$ac"]=$(( ${row_count_by_ac["$ac"]:-0} + 1 ))
  requirement_summary_by_ac["$ac"]="$(trim "${summary_cell:-}")"
  evidence_type_by_ac["$ac"]="$(trim "${type_cell:-}")"
  evidence_location_by_ac["$ac"]="$(trim "${location_cell:-}")"
  result_by_ac["$ac"]="$(trim "${result_cell:-}" | tr '[:upper:]' '[:lower:]')"
  residual_risk_by_ac["$ac"]="$(trim "${risk_cell:-}")"
done < <(
  awk '
    /^##[[:space:]]+AC Evidence[[:space:]]*$/ { in_section = 1; next }
    in_section && /^##[[:space:]]+/ { in_section = 0 }
    in_section { print }
  ' "$verify"
)

if [ "${#row_count_by_ac[@]}" -eq 0 ]; then
  echo "AC check failed:"
  echo " - VERIFY.md must include an AC Evidence table with one row per AC."
  exit 2
fi

issues=()
for ac in "${acs[@]}"; do
  count="${row_count_by_ac["$ac"]:-0}"
  if [ "$count" -eq 0 ]; then
    issues+=("Missing AC Evidence row for $ac.")
    continue
  fi
  if [ "$count" -gt 1 ]; then
    issues+=("Duplicate AC Evidence rows for $ac.")
    continue
  fi
  meaningful "${requirement_summary_by_ac["$ac"]:-}" true || issues+=("$ac missing Requirement Summary.")
  meaningful "${evidence_type_by_ac["$ac"]:-}" false || issues+=("$ac missing Evidence Type.")
  meaningful "${evidence_location_by_ac["$ac"]:-}" false || issues+=("$ac missing Evidence Location.")
  result="${result_by_ac["$ac"]:-}"
  if ! printf '%s' "$result" | grep -Eq '^(pass|fail|conditional|skipped)$'; then
    issues+=("$ac has invalid Result '$result'. Use pass/fail/conditional/skipped.")
  elif [ "$result" = "fail" ]; then
    issues+=("$ac Result is fail.")
  fi
  meaningful "${residual_risk_by_ac["$ac"]:-}" true || issues+=("$ac missing Residual Risk. Use 'none' when there is no residual risk.")
done

if [ "${#issues[@]}" -gt 0 ]; then
  echo "AC check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "AC check passed: ${#acs[@]} AC ids have complete AC Evidence rows."
