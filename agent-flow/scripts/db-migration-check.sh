#!/usr/bin/env bash
#
# db-migration-check — agent-flow gate
#
# Verifies that changes involving database schema modifications include rollback SQL
# or rollback steps. For Heavy/Standard changes that touch migration/schema files,
# checks whether corresponding rollback files exist.
#
# Usage:
#   bash agent-flow/scripts/db-migration-check.sh --change-dir <path> [--project-root <path>]
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
      echo "Usage: db-migration-check.sh --change-dir <change-dir> [--project-root <path>]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ] || [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi

# --- Only run for Heavy/Standard changes ---
change_file="$change_dir/CHANGE.md"
flow="Unknown"
if [ -f "$change_file" ]; then
  if grep -Eiq '\[x\][[:space:]]+Heavy' "$change_file"; then flow="Heavy"
  elif grep -Eiq '\[x\][[:space:]]+Standard' "$change_file"; then flow="Standard"
  elif grep -Eiq '\[x\][[:space:]]+Light' "$change_file"; then flow="Light"
  elif grep -Eiq '\[x\][[:space:]]+Emergency' "$change_file"; then flow="Emergency"
  fi
fi

if [ "$flow" != "Heavy" ] && [ "$flow" != "Standard" ]; then
  echo "SKIP: db-migration-check is only relevant for Standard and Heavy changes (current: $flow)"
  exit 0
fi

# --- Check for explicit rollback-not-needed declaration ---
if grep -Eiq 'rollback:\s*(not-needed|schema-only-add|none|not applicable)' "$change_file" 2>/dev/null; then
  echo "=== Database Migration Check ==="
  echo ""
  echo "✅ Rollback explicitly declared as not-needed in CHANGE.md. Skipping rollback check."
  echo "db-migration-check passed."
  exit 0
fi

# --- Check TASKS.md write_files for migration/schema files ---
tasks_file="$change_dir/TASKS.md"
has_migration=false
rollback_exists=false
migration_files=()

if [ -f "$tasks_file" ]; then
  # Extract write_files section
  in_write=false
  while IFS= read -r line; do
    if echo "$line" | grep -Eq '^\s*write_files\s*:'; then
      in_write=true
      continue
    fi
    if [ "$in_write" = true ]; then
      if echo "$line" | grep -Eq '^\s*##\s+|^\s*[A-Za-z0-9_-]+\s*:\s*$'; then
        in_write=false
        continue
      fi
      if echo "$line" | grep -Eq '^\s*-\s+(.+)'; then
        file_val="$(echo "$line" | sed -E 's/^\s*-\s+//' | sed -E "s/^['\x60]|['\x60]$//g" | xargs)"
        # Check if it looks like a migration/schema file
        if echo "$file_val" | grep -Eiq 'migration|schema|sql/|db/|database/|prisma/|flyway|liquibase|\.sql$'; then
          has_migration=true
          migration_files+=("$file_val")
        fi
      fi
    fi
  done < "$tasks_file"
fi

# --- Also check DESIGN.md for schema declarations ---
design_file="$change_dir/DESIGN.md"
design_declares_schema=false
if [ -f "$design_file" ]; then
  if grep -Eiq 'CREATE\s+TABLE|ALTER\s+TABLE|schema\s+change|database\s+migration|new\s+table|new\s+column|add\s+column|drop\s+column|modify\s+column' "$design_file"; then
    design_declares_schema=true
  fi
fi

echo "=== Database Migration Check ==="

if [ "$has_migration" = true ]; then
  echo "Migration/schema files declared in TASKS.md write_files:"
  for f in "${migration_files[@]}"; do echo "  - $f"; done

  # Check for corresponding rollback files
  for file in "${migration_files[@]}"; do
    full_path="$project_root/$file"
    dir="$(dirname "$full_path")"
    base_name="$(basename "$file")"
    base_noext="${base_name%.*}"
    ext="${base_name##*.}"

    for rb_name in "${base_noext}__rollback.${ext}" "${base_noext}_rollback.${ext}" "rollback_${base_noext}.${ext}" "rollback-${base_noext}.${ext}" "R${base_noext}.${ext}"; do
      if [ -f "$dir/$rb_name" ]; then
        echo "  ✅ Rollback file found: $dir/$rb_name"
        rollback_exists=true
        break
      fi
    done
  done
fi

echo ""
echo "============================================"

if [ "$has_migration" = true ] && [ "$rollback_exists" = false ]; then
  echo "⚠️  WARNING: Migration/schema files found but no rollback files detected."
  for f in "${migration_files[@]}"; do echo "   - $f"; done
  echo ""
  echo "  Recommended actions:"
  echo "   1. Add rollback SQL files for each migration file."
  echo "   2. Or declare 'rollback: not-needed' in CHANGE.md."
  exit 0
fi

if [ "$design_declares_schema" = true ] && [ "$has_migration" = false ]; then
  echo "⚠️  WARNING: DESIGN.md mentions schema changes but no migration files found in write_files."
  echo "  If this change involves DB schema changes, add migration files to write_files."
  exit 0
fi

if [ "$has_migration" = true ] && [ "$rollback_exists" = true ]; then
  echo "✅ Rollback files detected for all migration files. db-migration-check passed."
  exit 0
fi

echo "db-migration-check passed. No schema migration concerns detected."

if [ "$has_migration" = false ] && [ "$design_declares_schema" = false ]; then
  echo "(No migration files or schema declarations to check.)"
fi
