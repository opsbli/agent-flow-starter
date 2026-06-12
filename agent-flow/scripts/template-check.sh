#!/usr/bin/env bash
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
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

project_root="$(cd "$project_root" 2>/dev/null && pwd || echo "$project_root")"
template_root="$project_root/agent-flow/templates"
schema_path="$project_root/agent-flow/rules/artifact-schema.json"
issues=()

required_templates=(
  STATE.md
  CHANGE.md
  REQUIREMENT.md
  REQUIREMENT_ALIGNED.md
  CODE_SCAN.md
  DESIGN.md
  PLAN.md
  TASKS.md
  VERIFY.md
  REPORT.md
  REVIEW.md
  AUDIT.md
  EVOLUTION.md
  ADR.md
  VERSION
)

for template in "${required_templates[@]}"; do
  [ -e "$template_root/$template" ] || issues+=("Missing template file: $template")
done

if [ ! -f "$schema_path" ]; then
  issues+=("Missing artifact schema: agent-flow/rules/artifact-schema.json")
else
  grep -q '"schemaVersion"' "$schema_path" || issues+=("artifact-schema.json missing schemaVersion.")
  grep -q '"artifacts"' "$schema_path" || issues+=("artifact-schema.json missing artifacts map.")
fi

require_text() {
  local template="$1" needle="$2"
  local path="$template_root/$template"
  [ -f "$path" ] || return 0
  grep -qF "$needle" "$path" || issues+=("$template missing required text: $needle")
}

require_text VERIFY.md "## AC Evidence"
require_text VERIFY.md "## Coverage Summary"
require_text VERIFY.md "## Machine Gate Summary"
require_text REQUIREMENT.md "AC-01"
require_text REQUIREMENT_ALIGNED.md "## Confirmed Acceptance Criteria"
require_text ADR.md "Proposed / Accepted / Deprecated / Superseded"
require_text ADR.md "## Supersedes"
require_text ADR.md "## Superseded By"
require_text EVOLUTION.md "Improvement Tracker"

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Template check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Template check passed."
