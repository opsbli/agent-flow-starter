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

project_root="$(cd "$project_root" 2>/dev/null && pwd || echo "$project_root")"
design_path="$change_dir/DESIGN.md"
if [ ! -f "$design_path" ]; then
  echo "SKIP: No DESIGN.md in $change_dir (Light change or not yet created)"
  exit 0
fi

issues=()

append_files_text() {
  local text=""
  while IFS= read -r file; do
    [ -f "$file" ] || continue
    text="$text"$'\n'"$(cat "$file" 2>/dev/null || true)"
  done
  printf '%s' "$text"
}

find_files_in_dirs() {
  local dirs="$1"
  local extension_regex="$2"
  local dir
  for dir in $dirs; do
    if [ -d "$project_root/$dir" ]; then
      find "$project_root/$dir" -type f 2>/dev/null | grep -Ei "$extension_regex" || true
    fi
  done
}

table_names="$(grep -Eio '\b(CREATE|ALTER)[[:space:]]+TABLE[[:space:]]+[`"'\''[]?[A-Za-z_][A-Za-z0-9_]*' "$design_path" 2>/dev/null | sed -E 's/^.*TABLE[[:space:]]+[`"'\''[]?//' | sort -u || true)"
if [ -n "$table_names" ]; then
  echo "--- Schema drift check ---"
  echo "Tables declared in DESIGN.md: $(printf '%s' "$table_names" | paste -sd ', ' -)"
  schema_files="$(find_files_in_dirs 'migrations schema sql db database prisma src/main/resources/db' '\.(sql|xml|ya?ml|json|prisma|ts|js|java|kt)$' || true)"
  if [ -z "$schema_files" ]; then
    echo "  No schema/migration directories found. Skipping schema drift check."
  else
    schema_text="$(printf '%s\n' "$schema_files" | append_files_text)"
    while IFS= read -r table; do
      if [ -n "$table" ] && ! printf '%s' "$schema_text" | grep -qF "$table"; then
        issues+=("SCHEMA_DRIFT: Table '$table' declared in DESIGN.md but not found in schema/migration files.")
      fi
    done <<< "$table_names"
  fi
fi

routes="$(grep -Eo '(^|[^A-Za-z0-9_.-])/[A-Za-z][A-Za-z0-9_{}/:.-]*' "$design_path" 2>/dev/null | sed 's/^[^/]*//' | grep -Ev '\.(md|ps1|sh|java|ts|tsx|js|jsx)$|node_modules|\.git' | sort -u || true)"
if [ -n "$routes" ]; then
  echo ""
  echo "--- API route drift check ---"
  echo "Routes declared in DESIGN.md:"
  printf '%s\n' "$routes" | sed 's/^/  - /'
  echo "  NOTE: Route drift check is heuristic. Review route matches manually."
fi

perms="$(
  grep -Eo '@SaCheckPermission[[:space:]]*\([[:space:]]*["'\''][^"'\'']+' "$design_path" 2>/dev/null | sed -E 's/^.*["'\'']//' || true
  grep -Eio 'permission[-_ ]?code[[:space:]]*[:|][[:space:]]*[A-Z][A-Z0-9_:.-]+' "$design_path" 2>/dev/null | sed -E 's/^.*[:|][[:space:]]*//' || true
)"
perms="$(printf '%s\n' "$perms" | grep -v '^$' | sort -u || true)"
if [ -n "$perms" ]; then
  echo ""
  echo "--- Permission drift check ---"
  echo "Permission codes declared in DESIGN.md: $(printf '%s' "$perms" | paste -sd ', ' -)"
  source_files="$(find_files_in_dirs 'src app modules services common shared packages' '\.(java|kt|ts|tsx|js|jsx|vue)$' || true)"
  if [ -z "$source_files" ]; then
    echo "  No source directories found. Skipping permission drift check."
  else
    source_text="$(printf '%s\n' "$source_files" | append_files_text)"
    while IFS= read -r perm; do
      if [ -n "$perm" ] && ! printf '%s' "$source_text" | grep -qF "$perm"; then
        issues+=("PERM_DRIFT: Permission code '$perm' declared in DESIGN.md but not found in source files.")
      fi
    done <<< "$perms"
  fi
fi

if grep -Eiq '(workflow|state[[:space:]]+machine|status[[:space:]]+machine|Status[[:space:]]+Vocabulary|Status[[:space:]]+Mapping)' "$design_path" &&
   ! grep -Eiq '\b(no|not|without)\b.{0,80}(workflow|state[[:space:]]+machine|status)' "$design_path"; then
  echo ""
  echo "--- Workflow/status drift check ---"
  if ! grep -Eiq '^##[[:space:]]*Status[[:space:]]+Mapping' "$design_path"; then
    issues+=("WORKFLOW_DRIFT: Design mentions workflow/status but lacks Status Mapping section.")
  fi
  if ! grep -Eiq '^##[[:space:]]*Legacy[[:space:]]+Compatibility' "$design_path"; then
    issues+=("WORKFLOW_DRIFT: Design mentions workflow/status but lacks Legacy Compatibility section.")
  fi
fi

echo ""
echo "============================================"
if [ "${#issues[@]}" -gt 0 ]; then
  echo "Code-drift check found ${#issues[@]} issue(s):"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Code-drift check passed. No drift detected between DESIGN.md and live code."
