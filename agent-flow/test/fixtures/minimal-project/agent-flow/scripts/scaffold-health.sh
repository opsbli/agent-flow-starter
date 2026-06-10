#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/../.." && pwd)"

required=(
  "agent-flow/GO.md"
  "agent-flow/manifest.yaml"
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
  "agent-flow/templates/STATE.md"
  "agent-flow/templates/CHANGE.md"
  "agent-flow/templates/REQUIREMENT.md"
  "agent-flow/templates/CODE_SCAN.md"
  "agent-flow/templates/DESIGN.md"
  "agent-flow/templates/PLAN.md"
  "agent-flow/templates/TASKS.md"
  "agent-flow/templates/VERIFY.md"
  "agent-flow/templates/REPORT.md"
  "agent-flow/templates/REVIEW.md"
  "agent-flow/templates/AUDIT.md"
  "agent-flow/templates/LOG_ENTRY.md"
  "agent-flow/templates/INIT_CHECKLIST.md",
  "agent-flow/templates/CANCEL.md",
  "agent-flow/templates/ROLLBACK.md"
  "agent-flow/knowledge/known-good-baselines.md"
  "agent-flow/VERSION"
  "agent-flow/UPGRADE.md"
  "agent-flow/scripts/init-project.ps1"
  "agent-flow/scripts/init-project.sh"
  "agent-flow/scripts/run-verify.ps1"
  "agent-flow/scripts/new-change.ps1"
  "agent-flow/scripts/next-step.ps1"
  "agent-flow/scripts/alignment-check.ps1"
  "agent-flow/scripts/ac-check.ps1"
  "agent-flow/scripts/drift-check.ps1"
  "agent-flow/scripts/scaffold-health.ps1"
  "agent-flow/scripts/run-verify.sh"
  "agent-flow/scripts/new-change.sh"
  "agent-flow/scripts/next-step.sh"
  "agent-flow/scripts/alignment-check.sh"
  "agent-flow/scripts/ac-check.sh"
  "agent-flow/scripts/drift-check.sh"
  "agent-flow/scripts/scaffold-health.sh",
  "agent-flow/scripts/install-agent-flow.ps1",
  "agent-flow/scripts/install-agent-flow.sh",
  "agent-flow/scripts/code-drift-check.ps1",
  "agent-flow/scripts/code-drift-check.sh",
  "agent-flow/test/README.md",
  "agent-flow/test/fixtures/minimal-project/README.md",
  "agent-flow/test/test-scripts/test-new-change.ps1",
  "agent-flow/test/test-scripts/test-new-change.sh"
)

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
