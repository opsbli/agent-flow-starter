#!/usr/bin/env bash
# Check code drift against DESIGN.md declarations for Standard/Heavy changes.
#
# Reads DESIGN.md from a change directory and checks whether the actual code
# matches what was declared. Covers schema, API routes, and permission codes.
#
# Usage:
#   bash code-drift-check.sh --change-dir agent-flow/changes/my-change
#   bash code-drift-check.sh --change-dir agent-flow/changes/my-change --project-root /path/to/project

set -euo pipefail

# --- Parse arguments ---
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
      echo "Usage: $0 --change-dir <path> [--project-root <path>]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ]; then
  echo "ERROR: --change-dir is required" >&2
  exit 2
fi

if [ ! -d "$change_dir" ]; then
  echo "ERROR: ChangeDir not found: $change_dir" >&2
  exit 2
fi

project_root="$(cd "$project_root" && pwd 2>/dev/null || echo "$project_root")"

# --- Helper: check if a file exists ---
has_file() {
  [ -f "$1" ]
}

# --- Read DESIGN.md ---
design_path="$change_dir/DESIGN.md"
if [ ! -f "$design_path" ]; then
  echo "SKIP: No DESIGN.md in $change_dir (Light change or not yet created)"
  exit 0
fi

issues=()

# --- 1. Schema drift ---
echo "--- Schema drift check ---"
# Extract table names from CREATE TABLE / ALTER TABLE patterns
table_names=$(grep -oiP '(?i)(CREATE TABLE|ALTER TABLE|TABLE\s+)\s*`?(\w+)' "$design_path" 2>/dev/null | grep -oP '\w+' | tail -n +2 || true)

if [ -n "$table_names" ]; then
  echo "Tables declared in DESIGN.md: $(echo "$table_names" | tr '\n' ', ')"

  # Look for migration/schema files
  schema_found=false
  for dir in migrations schema sql db database prisma "src/main/resources/db"; do
    if [ -d "$project_root/$dir" ]; then
      schema_found=true
      # Search for table names in migration files
      for table in $table_names; do
        if ! grep -rq "$table" "$project_root/$dir" 2>/dev/null; then
          issues+=("SCHEMA_DRIFT: Table '$table' declared in DESIGN.md but not found in $dir/")
        fi
      done
    fi
  done

  if [ "$schema_found" = false ]; then
    echo "  No schema/migration directories found. Skipping schema drift check."
  fi
fi

# --- 2. API route drift (heuristic) ---
echo ""
echo "--- API route drift check ---"
# Extract route-like paths (starting with /)
routes=$(grep -oP '`?(/[a-zA-Z][a-zA-Z0-9_{}/:.\-]*)' "$design_path" 2>/dev/null | grep -vE '\.md$|\.ps1$|\.sh$|\.java$|\.ts$|\.js$|node_modules|\.git' | sort -u || true)

if [ -n "$routes" ]; then
  echo "Routes declared in DESIGN.md:"
  echo "$routes" | while IFS= read -r r; do echo "  - $r"; done
  echo "  NOTE: Route drift check is heuristic. Review route matches manually."
fi

# --- 3. Permission drift ---
echo ""
echo "--- Permission drift check ---"
# Extract @SaCheckPermission values and permission code patterns
perms=$(grep -oP '@SaCheckPermission\s*\(\s*["'"'"']\K[^"'"'"']+' "$design_path" 2>/dev/null || true)
# Also extract from permission table
perm_table_codes=$(grep -oP '权限码\s*\|[^|]+\|\s*\K[A-Z_]{3,}' "$design_path" 2>/dev/null || true)

all_perms=$( (echo "$perms"; echo "$perm_table_codes") | sort -u | grep -v '^$' || true)

if [ -n "$all_perms" ]; then
  echo "Permission codes declared in DESIGN.md: $(echo "$all_perms" | tr '\n' ', ')"

  # Search source files for permission codes
  src_found=false
  for dir in src app modules services common shared packages; do
    if [ -d "$project_root/$dir" ]; then
      src_found=true
      for perm in $all_perms; do
        if ! grep -rq "$perm" "$project_root/$dir" 2>/dev/null; then
          issues+=("PERM_DRIFT: Permission code '$perm' declared in DESIGN.md but not found in $dir/")
        fi
      done
    fi
  done

  if [ "$src_found" = false ]; then
    echo "  No source directories found. Skipping permission drift check."
  fi
fi

# --- 4. Workflow/status drift ---
if grep -qiE '状态机|state machine|status machine|Status Vocabulary|Status Mapping' "$design_path" 2>/dev/null; then
  echo ""
  echo "--- Workflow/status drift check ---"

  if ! grep -q "Status Mapping" "$design_path" 2>/dev/null; then
    issues+=("WORKFLOW_DRIFT: Design mentions state machine but lacks Status Mapping section.")
  fi
  if ! grep -q "Legacy Compatibility" "$design_path" 2>/dev/null; then
    issues+=("WORKFLOW_DRIFT: Design mentions state machine but lacks Legacy Compatibility section.")
  fi
fi

# --- Summary ---
echo ""
echo "============================================"
if [ "${#issues[@]}" -gt 0 ]; then
  echo "Code-drift check found ${#issues[@]} issue(s):"
  printf ' - %s\n' "${issues[@]}"
  exit 2
else
  echo "Code-drift check passed. No drift detected between DESIGN.md and live code."
  exit 0
fi
