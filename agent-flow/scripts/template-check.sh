#!/usr/bin/env bash
# Validate templates against artifact-schema.json — dynamically reads rules from schema.
# Usage: bash agent-flow/scripts/template-check.sh [--project-root <path>]
set -euo pipefail

project_root="."

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: template-check.sh [--project-root <path>]"
      exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

project_root="$(cd "$project_root" 2>/dev/null && pwd || echo "$project_root")"
template_root="$project_root/agent-flow/templates"
schema_path="$project_root/agent-flow/rules/artifact-schema.json"
issues=()

# Required template files
required_templates=(
  STATE.md CHANGE.md REQUIREMENT.md REQUIREMENT_ALIGNED.md
  CODE_SCAN.md DESIGN.md PLAN.md TASKS.md VERIFY.md
  REPORT.md REVIEW.md AUDIT.md EVOLUTION.md
  ADR.md CANCEL.md ROLLBACK.md INIT_CHECKLIST.md LOG_ENTRY.md
  VERSION
)

for template in "${required_templates[@]}"; do
  [ -e "$template_root/$template" ] || issues+=("Missing template file: $template")
done

# Validate schema structure
if [ ! -f "$schema_path" ]; then
  issues+=("Missing artifact schema: agent-flow/rules/artifact-schema.json")
else
  grep -q '"schemaVersion"' "$schema_path" || issues+=("artifact-schema.json missing schemaVersion.")
  grep -q '"artifacts"' "$schema_path" || issues+=("artifact-schema.json missing artifacts map.")
fi

# Extract JSON array values (strings inside [] that are NOT object keys)
# Matches patterns like: "value" — but not "key":
json_array_values() {
  local block="$1"
  # Find lines with quoted strings NOT followed by a colon
  echo "$block" | grep -E '^\s+"[^"]+"' | grep -v ':' | sed 's/.*"\([^"]*\)".*/\1/' || true
}

# Dynamically validate each artifact from the schema
if [ -f "$schema_path" ]; then
  schema_text=$(cat "$schema_path")
  
  # Extract artifact names — all top-level keys under "artifacts"
  artifact_names=$(echo "$schema_text" | sed -n '/"artifacts":/,/^}/p' | grep -E '^\s+"[A-Za-z_]+\.(md|json)"' | sed 's/.*"\([^"]*\)".*/\1/' || true)

  for artifact in $artifact_names; do
    tpl_path="$template_root/$artifact"
    [ -f "$tpl_path" ] || continue
    tpl_text=$(cat "$tpl_path")

    # Extract this artifact's block from the schema
    block=$(echo "$schema_text" | sed -n "/\"$artifact\"/,/^[[:space:]]*}/p" || true)
    [ -n "$block" ] || continue

    # --- Check requiredSections ---
    # Extract the section block under requiredSections
    sections_block=$(echo "$block" | sed -n '/"requiredSections":/,/^[[:space:]]*\]/p' || true)
    if [ -n "$sections_block" ]; then
      sections=$(json_array_values "$sections_block")
      for section in $sections; do
        if ! echo "$tpl_text" | grep -Eq "^##[[:space:]]+$section"; then
          issues+=("$artifact missing required section: $section")
        fi
      done
    fi

    # --- Check requiredText ---
    text_block=$(echo "$block" | sed -n '/"requiredText":/,/^[[:space:]]*\]/p' || true)
    if [ -n "$text_block" ]; then
      text_checks=$(json_array_values "$text_block")
      for text in $text_checks; do
        if ! echo "$tpl_text" | grep -qF "$text"; then
          issues+=("$artifact missing required text: $text")
        fi
      done
    fi

    # --- Check machineCheckKeys ---
    keys_block=$(echo "$block" | sed -n '/"machineCheckKeys":/,/^[[:space:]]*\]/p' || true)
    if [ -n "$keys_block" ]; then
      keys=$(json_array_values "$keys_block")
      for key in $keys; do
        if ! echo "$tpl_text" | grep -Eq "^$key:"; then
          issues+=("$artifact missing machine-check key: $key")
        fi
      done
    fi
  done
fi

# Check template VERSION matches schemaVersion
tpl_version="$template_root/VERSION"
if [ -f "$tpl_version" ] && [ -f "$schema_path" ]; then
  sv=$(grep '"schemaVersion"' "$schema_path" | sed 's/.*: *"\([^"]*\)".*/\1/' 2>/dev/null || echo "?")
  tv=$(cat "$tpl_version" | tr -d '[:space:]')
  [ "$sv" = "$tv" ] || issues+=("Template VERSION ($tv) does not match artifact-schema.json schemaVersion ($sv).")
fi

# Breaking change detection: validate existing changes against current schema
changes_dir="$project_root/agent-flow/changes"
if [ -d "$changes_dir" ]; then
  for change in "$changes_dir"/*/; do
    [ "$(basename "$change")" = ".gitkeep" ] && continue
    [ ! -d "$change" ] && continue

    # Check VERIFY.md against current schema if it exists
    if [ -f "$change/VERIFY.md" ] && [ -f "$template_root/VERIFY.md" ]; then
      # Check that the change's VERIFY.md has the required sections from current schema
      sections=$(grep -E '^\s+"[A-Za-z ]+"' -A20 "$schema_path" | sed -n '/"VERIFY.md"/,/^[[:space:]]*}/p' | grep '"requiredSections"' -A5 | grep -E '^\s+"[^"]+"' | grep -v ':' | sed 's/.*"\([^"]*\)".*/\1/' || true)
      for section in $sections; do
        if ! grep -Eq "^##[[:space:]]+$section" "$change/VERIFY.md" 2>/dev/null; then
          issues+=("BREAKING: Change '$(basename "$change")' VERIFY.md missing new required section: $section (from schema v$sv)")
        fi
      done
    fi
  done
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Template check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Template check passed."
echo "  Schema version: $sv | Templates version: $tv"
