#!/usr/bin/env bash
#
# api-compatibility-check — agent-flow gate
#
# Parses DESIGN.md API / Permission / Auth decisions and scans project source
# files for drift between declared contracts and live code.
#
# Usage:
#   bash agent-flow/scripts/api-compatibility-check.sh --change-dir <path> [--project-root <path>]
#

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
      echo "Usage: api-compatibility-check.sh --change-dir <change-dir> [--project-root <path>]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ] || [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi

design_file="$change_dir/DESIGN.md"
if [ ! -f "$design_file" ]; then
  echo "SKIP: No DESIGN.md in $change_dir (Light change or not yet created)"
  exit 0
fi

design_text="$(cat "$design_file")"

if ! echo "$design_text" | grep -Eiq '##\s*API\s*Design|##\s*API\s*/\s*Permission'; then
  echo "SKIP: DESIGN.md has no API / Permission / Auth decisions section"
  exit 0
fi

echo "=== API Compatibility Check ==="
warnings=()

# --- 1. Extract declared REST paths ---
api_routes=$(echo "$design_text" | grep -oE '(/[A-Za-z][A-Za-z0-9_{}/:.\-]*)' | \
  grep -vE '\.(md|ps1|sh|java|ts|tsx|js|jsx)$' | \
  grep -E '^/(api/|v[0-9]+/|rest/|rpc/|graphql|webhook|auth/)' | sort -u || true)

if [ -n "$api_routes" ]; then
  echo "API routes declared in DESIGN.md:"
  echo "$api_routes" | sed 's/^/  /'
  echo "Scanning source files for route references..."

  source_files=$(find "$project_root/src" "$project_root/app" "$project_root/modules" \
    "$project_root/routes" "$project_root/controllers" "$project_root/handlers" \
    -type f 2>/dev/null | grep -E '\.(java|kt|ts|tsx|js|jsx|vue|py|go|rs)$' | head -200 || true)

  if [ -n "$source_files" ]; then
    source_text="$(cat $source_files 2>/dev/null || true)"
    while IFS= read -r route; do
      [ -z "$route" ] && continue
      escaped_route="$(printf '%s' "$route" | sed 's/[][\.*^$()+?{}|]/\\&/g')"
      if ! echo "$source_text" | grep -qF "$route"; then
        warnings+=("API_COMPAT_WARN: Route '$route' declared in DESIGN.md but not found in source files.")
      fi
    done <<< "$api_routes"
  else
    echo "  No source directories found. Skipping route scan."
  fi
else
  echo "No API routes with standard prefix found in DESIGN.md. Skipping route scan."
fi

# --- 2. Extract declared permission codes ---
declared_perms=$(echo "$design_text" | \
  grep -oE '@SaCheckPermission\s*\(\s*["'\'']([^"'\'']+)["'\'']' | \
  sed -E 's/@SaCheckPermission\s*\(\s*["'\'']([^"'\'']+)["'\''][)]*/\1/' || true)

# Permission Code rows in decision table
perm_table_perms=$(echo "$design_text" | \
  grep -oiE '\|.*\|\s*(permission|perm\.code|permission.code)\s*[:|]\s*([A-Za-z][A-Za-z0-9_:.\-]+)' | \
  sed -E 's/.*\|[^|]+\|\s*//' || true)
decision_table_perms=$(echo "$design_text" | awk -F'|' '
  function trim(v) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
    return v
  }
  tolower(trim($2)) == "permission code" {
    decision = tolower(trim($3))
    value = trim($4)
    if (decision ~ /^(new|modified|deleted)$/ && value !~ /^(pending|unchanged|not-applicable|none|n\/a)$/) {
      print value
    }
  }
')

declared_perms=$(printf '%s\n%s\n%s\n' "$declared_perms" "$perm_table_perms" "$decision_table_perms" | sort -u | grep -vE '^(pending|unchanged|not-applicable|none|n/a)$' || true)

if [ -n "$declared_perms" ]; then
  echo ""
  echo "Permission codes declared in DESIGN.md:"
  echo "$declared_perms" | sed 's/^/  /'
  echo "Scanning source files for permission references..."

  source_files=$(find "$project_root/src" "$project_root/app" "$project_root/modules" \
    -type f 2>/dev/null | grep -E '\.(java|kt|ts|tsx|js|jsx|vue|py)$' | head -200 || true)

  if [ -n "$source_files" ]; then
    source_text="$(cat $source_files 2>/dev/null || true)"
    while IFS= read -r perm; do
      [ -z "$perm" ] && continue
      if ! echo "$source_text" | grep -qF "$perm"; then
        warnings+=("API_COMPAT_WARN: Permission code '$perm' declared in DESIGN.md but not found in source files.")
      fi
    done <<< "$declared_perms"
  else
    echo "  No source directories found. Skipping permission scan."
  fi
fi

# --- 3. Check for modified/deleted API status ---
if echo "$design_text" | grep -Eiq '^\s*\|\s*REST Path\s*\|\s*(modified|deleted)\s*\|'; then
  echo ""
  echo "WARNING: DESIGN.md marks REST Path as modified or deleted."
  echo "  This change may break existing API consumers."
  warnings+=("API_COMPAT_WARN: DESIGN.md declares modified or deleted REST Path — breaking change risk.")
fi

# --- Output ---
echo ""
echo "============================================"
if [ "${#warnings[@]}" -gt 0 ]; then
  echo "API compatibility check found ${#warnings[@]} warning(s):"
  for w in "${warnings[@]}"; do echo " - $w"; done
  echo ""
  echo "NOTE: This check is heuristic. Review each warning manually."
  echo "To enable strict mode (fail on warnings), set strict_compatibility: true in manifest.yaml."
  exit 0
fi

echo "API compatibility check passed. No drift detected between DESIGN.md API declarations and live code."

if [ -z "$api_routes" ] && [ -z "$declared_perms" ]; then
  echo "(No API routes or permission codes to check.)"
fi
