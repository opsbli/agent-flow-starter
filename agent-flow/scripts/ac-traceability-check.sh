#!/usr/bin/env bash
# Verify AC traceability: each AC-XX from REQUIREMENT.md must appear in DESIGN.md,
# TASKS.md, VERIFY.md, and REPORT.md.
set -euo pipefail

change_dir=""
repair=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    --repair|-Repair)
      repair=true; shift ;;
    -h|--help)
      echo "Usage: ac-traceability-check.sh --change-dir <path> [--repair]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ]; then
  echo "Missing --change-dir" >&2
  exit 2
fi

req_file="$change_dir/REQUIREMENT.md"
design_file="$change_dir/DESIGN.md"
tasks_file="$change_dir/TASKS.md"
verify_file="$change_dir/VERIFY.md"
report_file="$change_dir/REPORT.md"

if [ ! -f "$req_file" ]; then
  echo "[SKIP] REQUIREMENT.md not found; cannot verify AC traceability."
  exit 0
fi

acs="$(grep -Eo 'AC-[0-9]+' "$req_file" | sort -u | tr '\n' ' ' 2>/dev/null || true)"
if [ -z "$acs" ]; then
  echo "[SKIP] No AC-XX references found in REQUIREMENT.md. Traceability check not applicable."
  exit 0
fi

ac_count="$(printf '%s\n' "$acs" | wc -w | tr -d ' ')"
echo "AC Traceability Check"
echo "   Change: $change_dir"
echo "   REQ ACs: $ac_count ($acs)"
echo

total_missing=0
declare -A missing_map
declare -A file_map=(
  ["DESIGN.md"]="$design_file"
  ["TASKS.md"]="$tasks_file"
  ["VERIFY.md"]="$verify_file"
  ["REPORT.md"]="$report_file"
)

check_file() {
  local label="$1" file="$2" missing="" ac
  if [ ! -f "$file" ]; then
    echo "   [SKIP] $label not present"
    missing_map["$label"]=""
    return
  fi

  for ac in $acs; do
    if ! grep -qF "$ac" "$file"; then
      missing="$missing $ac"
      total_missing=$((total_missing + 1))
    fi
  done
  missing_map["$label"]="$missing"

  if [ -z "$missing" ]; then
    echo "   [PASS] $label all ACs present ($ac_count/$ac_count)"
  else
    echo "   [FAIL] $label missing $(printf '%s\n' "$missing" | wc -w | tr -d ' ') AC(s):$missing"
  fi
}

check_file "DESIGN.md" "$design_file"
check_file "TASKS.md" "$tasks_file"
check_file "VERIFY.md" "$verify_file"
check_file "REPORT.md" "$report_file"

echo
if [ "$total_missing" -eq 0 ]; then
  echo "[PASS] AC Traceability: all $ac_count ACs traced through all artifacts"
else
  echo "[FAIL] AC Traceability: $total_missing missing AC references"
  echo
  echo "Traceability Matrix:"
  printf "%-20s%-15s%-15s%-15s%-15s\n" "AC ID" "DESIGN.md" "TASKS.md" "VERIFY.md" "REPORT.md"
  for ac in $acs; do
    printf "%-20s" "$ac"
    for label in "DESIGN.md" "TASKS.md" "VERIFY.md" "REPORT.md"; do
      file="${file_map[$label]}"
      mark="PASS"
      if [ ! -f "$file" ]; then
        mark="SKIP"
      elif printf ' %s ' "${missing_map[$label]:-}" | grep -qF " $ac "; then
        mark="FAIL"
      fi
      printf "%-15s" "$mark"
    done
    printf "\n"
  done

  if [ "$repair" = true ] && [ -f "$verify_file" ]; then
    missing_verify="${missing_map["VERIFY.md"]:-}"
    if [ -n "$missing_verify" ]; then
      {
        echo
        echo "## AC Traceability (auto-annotated by ac-traceability-check)"
        echo
        echo "> The following ACs are defined in REQUIREMENT.md but not yet referenced in VERIFY.md."
        echo "> Fill in verification evidence before declaring completion."
        echo
        echo "| AC | Verification Evidence |"
        echo "|----|-----------------------|"
        for ac in $missing_verify; do
          echo "| $ac | (TODO: add verification evidence) |"
        done
      } >> "$verify_file"
      echo "[PASS] VERIFY.md annotated."
    fi
  fi

  exit 2
fi

echo
echo "Tip: AC IDs must be consistent. Use AC-01, AC-02 format in all change artifacts."
