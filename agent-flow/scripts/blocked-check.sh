#!/usr/bin/env bash
set -euo pipefail

change_dir=""
project_root="."
manifest="agent-flow/manifest.yaml"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    --manifest|-Manifest)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      manifest="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 --change-dir <path> [--project-root <path>] [--manifest <path>]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ]; then
  echo "ERROR: --change-dir is required" >&2
  exit 2
fi

project_root="$(cd "$project_root" 2>/dev/null && pwd || echo "$project_root")"
manifest_path="$project_root/$manifest"

if [ ! -f "$manifest_path" ]; then
  echo "SKIP: Manifest not found at $manifest_path"
  exit 0
fi

blocked_rules="$(
  awk '
    /^[[:space:]]*blocked_if:[[:space:]]*$/ { in_section = 1; next }
    in_section && /^[[:space:]]*-/ {
      sub(/^[[:space:]]*-[[:space:]]*/, "")
      print
      next
    }
    in_section && /^[^[:space:]]/ { in_section = 0 }
    in_section && /^[[:space:]]{2}[A-Za-z0-9_-]+:[[:space:]]*$/ { in_section = 0 }
  ' "$manifest_path"
)"

if [ -z "$blocked_rules" ]; then
  echo "SKIP: No blocked_if rules defined in manifest.yaml"
  exit 0
fi

if [ ! -d "$change_dir" ]; then
  echo "ERROR: ChangeDir not found: $change_dir" >&2
  exit 2
fi

echo "=== Blocked-if check ==="
echo "Blocked rules active:"
printf '%s\n' "$blocked_rules" | while IFS= read -r rule; do echo "  - $rule"; done
echo ""

all_text=""
for file in "$change_dir"/*.md; do
  if [ -f "$file" ]; then
    all_text="$all_text"$'\n'"$(cat "$file" 2>/dev/null || true)"
  fi
done

tasks_path="$change_dir/TASKS.md"
if [ -f "$tasks_path" ]; then
  while IFS= read -r file_path; do
    fp="$(printf '%s' "$file_path" | sed 's/^[[:space:]]*-[[:space:]]*//; s/^`//; s/`$//; s/^"//; s/"$//; s/^'\''//; s/'\''$//')"
    case "$fp" in
      agent-flow/scripts/blocked-check.ps1|agent-flow/scripts/blocked-check.sh)
        continue
        ;;
    esac
    if [ -n "$fp" ] && [ -f "$project_root/$fp" ]; then
      all_text="$all_text"$'\n'"$(cat "$project_root/$fp" 2>/dev/null || true)"
    fi
  done < <(
    awk '
      /^[[:space:]]*write_files/ { in_section = 1; next }
      in_section && /^[[:space:]]*##[[:space:]]+/ { in_section = 0 }
      in_section && /^[[:space:]]*[A-Za-z0-9_-]+[[:space:]]*:[[:space:]]*$/ { in_section = 0 }
      in_section && /^[[:space:]]*-/ { print }
    ' "$tasks_path"
  )
fi

# Rule identifiers such as payment_bypass are metadata, not risky code evidence.
scan_text="$all_text"
while IFS= read -r rule_id; do
  [ -z "$rule_id" ] && continue
  scan_text="${scan_text//$rule_id/blocked_rule_id}"
done <<< "$blocked_rules"
all_text="$scan_text"

issues=()
while IFS= read -r rule; do
  case "$rule" in
    hard_delete_without_approval)
      if printf '%s' "$all_text" | grep -qiE '(DELETE[[:space:]]+FROM|DROP[[:space:]]+TABLE|TRUNCATE|DELETE[[:space:]]+WHERE)'; then
        if ! printf '%s' "$all_text" | grep -qiE '(approval|approved|reviewed|批准|确认|审核通过|# CANCEL)'; then
          issues+=("BLOCKED: hard_delete_without_approval - Found destructive SQL/operation without explicit approval marker.")
        fi
      fi
      ;;
    disable_security_filter)
      if printf '%s' "$all_text" | grep -qiE '(\.disable\(\)|\.permitAll\(\)|SecurityConfig|security\.ignoring|disable.*security|security.*bypass)'; then
        if ! printf '%s' "$all_text" | grep -qiE '(# EMERGENCY|# APPROVED|approved.*security|security review|安全审核)'; then
          issues+=("BLOCKED: disable_security_filter - Found security filter disable/circumvention pattern without explicit approval.")
        fi
      fi
      ;;
    bypass_auth_for_production)
      if printf '%s' "$all_text" | grep -qiE '(permitAll\(\)|\.anonymous\(\)|skipAuth|withoutAuth|noAuth|bypassAuth|@Anonymous)' &&
         printf '%s' "$all_text" | grep -qiE '(production|prod|live|public.?api|anonymous.*interface|生产|公开接口)'; then
        issues+=("BLOCKED: bypass_auth_for_production - Found auth bypass pattern combined with production/public route reference.")
      fi
      ;;
    direct_production_data_mutation)
      if printf '%s' "$all_text" | grep -qiE '(UPDATE[[:space:]]+.*SET|INSERT[[:space:]]+INTO)[[:space:]]+[[:alnum:]_]+' &&
         printf '%s' "$all_text" | grep -qiE '(production|prod|live|direct|execute|jdbcTemplate|Statement|native.*sql|生产|原生SQL)'; then
        issues+=("BLOCKED: direct_production_data_mutation - Found direct data mutation pattern combined with production/native execution.")
      fi
      ;;
    payment_bypass)
      if printf '%s' "$all_text" | grep -qiE '(payment|billing|charge|invoice|order.*paid|支付|账单|扣费|chargeback)' &&
         printf '%s' "$all_text" | grep -qiE '(skip|bypass|force|override|mark.*paid|绕过|跳过|直接.*完成)'; then
        issues+=("BLOCKED: payment_bypass - Found payment/billing logic modification with bypass pattern.")
      fi
      ;;
    *)
      search_term="${rule//_/ }"
      if printf '%s' "$all_text" | grep -qiF "$search_term"; then
        issues+=("BLOCKED: $rule - Rule triggered by text match in change artifacts.")
      fi
      ;;
  esac
done <<< "$blocked_rules"

echo ""
echo "============================================"
if [ "${#issues[@]}" -gt 0 ]; then
  echo "Blocked-if check found ${#issues[@]} violation(s):"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Blocked-if check passed. No blocked operations detected."
