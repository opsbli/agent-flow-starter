#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/../.." && pwd)"

required=(
  "agent-flow/GO.md"
  "agent-flow/FAQ.md"
  "agent-flow/READING.md"
  "agent-flow/manifest.yaml"
  "agent-flow/project-profiles.json"
  "agent-flow/rules/gates.txt"
  "agent-flow/rules/artifact-schema.json"
  "agent-flow/rules/code-scan-light.keys"
  "agent-flow/rules/code-scan-standard-heavy.keys"
  "agent-flow/rules/design-decision.keys"
  "agent-flow/rules/design-alignment.questions"
  "agent-flow/rules/plan-required.keys"
  "agent-flow/rules/plan-audit.keys"
  "agent-flow/rules/evolution.keys"
  "agent-flow/rules/closure-heavy-gates.keys"
  "agent-flow/core/principles.md"
  "agent-flow/core/source-of-truth.md"
  "agent-flow/core/autonomy-policy.md"
  "agent-flow/core/router.md"
  "agent-flow/core/code-first-context.md"
  "agent-flow/core/memory.md"
  "agent-flow/core/plan-guide.md"
  "agent-flow/core/audit.md"
  "agent-flow/core/logging.md"
  "agent-flow/core/evolution.md"
  "agent-flow/flows/light.md"
  "agent-flow/flows/standard.md"
  "agent-flow/flows/heavy.md"
  "agent-flow/flows/emergency.md"
  "agent-flow/templates/STATE.md"
  "agent-flow/templates/CHANGE.md"
  "agent-flow/templates/REQUIREMENT.md"
  "agent-flow/templates/REQUIREMENT_ALIGNED.md"
  "agent-flow/templates/CODE_SCAN.md"
  "agent-flow/templates/DESIGN.md"
  "agent-flow/templates/PLAN.md"
  "agent-flow/templates/TASKS.md"
  "agent-flow/templates/VERIFY.md"
  "agent-flow/templates/REPORT.md"
  "agent-flow/templates/REVIEW.md"
  "agent-flow/templates/AUDIT.md"
  "agent-flow/templates/LOG_ENTRY.md"
  "agent-flow/templates/INIT_CHECKLIST.md"
  "agent-flow/templates/CANCEL.md"
  "agent-flow/templates/ROLLBACK.md"
  "agent-flow/templates/VERSION"
  "agent-flow/knowledge/INDEX.md"
  "agent-flow/knowledge/improvement-tracker.md"
  "agent-flow/knowledge/known-good-baselines.md"
  "agent-flow/decisions/INDEX.md"
  "agent-flow/decisions/README.md"
  "agent-flow/VERSION"
  "agent-flow/UPGRADE.md"
  "agent-flow/scripts/_common.ps1"
  "agent-flow/scripts/_common.sh"
  "agent-flow/test/README.md"
  "agent-flow/test/fixtures/minimal-project/README.md"
  "agent-flow/test/test-scripts/test-new-change.ps1"
  "agent-flow/test/test-scripts/test-new-change.sh"
  "agent-flow/test/test-scripts/test-next-step.ps1"
  "agent-flow/test/test-scripts/test-next-step.sh"
  "agent-flow/test/test-scripts/test-gate-smoke.ps1"
  "agent-flow/test/test-scripts/test-gate-smoke.sh"
  "agent-flow/test/test-scripts/test-check-change.ps1"
  "agent-flow/test/test-scripts/test-check-change.sh"
)

gate_rules_path="$project_root/agent-flow/rules/gates.txt"
if [ ! -f "$gate_rules_path" ]; then
  echo "Missing scaffold files:"
  echo " - agent-flow/rules/gates.txt"
  exit 2
fi

while IFS= read -r gate || [ -n "$gate" ]; do
  gate="${gate#"${gate%%[![:space:]]*}"}"
  gate="${gate%"${gate##*[![:space:]]}"}"
  case "$gate" in
    ""|\#*) continue ;;
  esac
  required+=("$gate")
done < "$gate_rules_path"

missing=()
for file in "${required[@]}"; do
  if [ ! -e "$project_root/$file" ]; then
    missing+=("$file")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Missing scaffold files:"
  printf ' - %s\n' "${missing[@]}"
  exit 2
fi

echo "agent-flow scaffold health check passed."
