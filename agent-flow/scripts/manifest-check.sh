#!/usr/bin/env bash
set -euo pipefail

project_root="."
manifest="agent-flow/manifest.yaml"
strict_todo=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    --manifest|-Manifest)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      manifest="$2"; shift 2 ;;
    --strict-todo|-StrictTodo)
      strict_todo=true; shift ;;
    -h|--help)
      echo "Usage: manifest-check.sh [--project-root <path>] [--manifest agent-flow/manifest.yaml] [--strict-todo]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

project_root="$(cd "$project_root" 2>/dev/null && pwd || echo "$project_root")"
manifest_path="$project_root/$manifest"
if [ ! -f "$manifest_path" ]; then
  echo "Manifest not found: $manifest_path" >&2
  exit 2
fi

issues=()
warnings=()

require_text() {
  local label="$1" pattern="$2"
  if ! grep -Eq "$pattern" "$manifest_path"; then
    issues+=("Missing $label")
  fi
}

for section in project code_map change_storage risk_rules verification gates; do
  require_text "section: $section" "^$section:"
done

for rule in heavy_if destructive_gate blocked_if; do
  require_text "risk_rules.$rule" "^[[:space:]]+$rule:"
done

required_blocked=(
  hard_delete_without_approval
  disable_security_filter
  bypass_auth_for_production
  direct_production_data_mutation
  payment_bypass
)
for rule in "${required_blocked[@]}"; do
  require_text "blocked_if rule: $rule" "^[[:space:]]*-[[:space:]]+$rule[[:space:]]*$"
done

required_gates=(
  agent-flow/scripts/init-project.ps1
  agent-flow/scripts/init-project.sh
  agent-flow/scripts/install-agent-flow.ps1
  agent-flow/scripts/install-agent-flow.sh
  agent-flow/scripts/new-change.ps1
  agent-flow/scripts/new-change.sh
  agent-flow/scripts/next-step.ps1
  agent-flow/scripts/next-step.sh
  agent-flow/scripts/sync-state.ps1
  agent-flow/scripts/sync-state.sh
  agent-flow/scripts/state-check.ps1
  agent-flow/scripts/state-check.sh
  agent-flow/scripts/alignment-check.ps1
  agent-flow/scripts/alignment-check.sh
  agent-flow/scripts/task-boundary-check.ps1
  agent-flow/scripts/task-boundary-check.sh
  agent-flow/scripts/manifest-check.ps1
  agent-flow/scripts/manifest-check.sh
  agent-flow/scripts/closure-check.ps1
  agent-flow/scripts/closure-check.sh
  agent-flow/scripts/run-verify.ps1
  agent-flow/scripts/run-verify.sh
  agent-flow/scripts/verify-backend.ps1
  agent-flow/scripts/verify-backend.sh
  agent-flow/scripts/verify-module.ps1
  agent-flow/scripts/verify-module.sh
  agent-flow/scripts/ac-check.ps1
  agent-flow/scripts/ac-check.sh
  agent-flow/scripts/code-drift-check.ps1
  agent-flow/scripts/code-drift-check.sh
  agent-flow/scripts/blocked-check.ps1
  agent-flow/scripts/blocked-check.sh
  agent-flow/scripts/drift-check.ps1
  agent-flow/scripts/drift-check.sh
  agent-flow/scripts/scaffold-health.ps1
  agent-flow/scripts/scaffold-health.sh
)

for gate in "${required_gates[@]}"; do
  require_text "gate entry: $gate" "^[[:space:]]*-[[:space:]]+$gate[[:space:]]*$"
  if [ ! -f "$project_root/$gate" ]; then
    issues+=("Gate file does not exist: $gate")
  fi
done

todo_count="$(grep -o 'TODO_' "$manifest_path" | wc -l | tr -d ' ')"
if [ "$todo_count" -gt 0 ]; then
  message="Manifest has $todo_count unresolved TODO_ value(s)."
  if [ "$strict_todo" = true ]; then
    issues+=("$message")
  else
    warnings+=("$message")
  fi
fi

if [ "${#warnings[@]}" -gt 0 ]; then
  echo "Manifest warnings:"
  printf ' - %s\n' "${warnings[@]}"
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Manifest check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Manifest check passed."
