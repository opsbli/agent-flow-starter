#!/usr/bin/env bash
#
# actionlint-check — agent-flow gate
#
# Validates GitHub Actions workflow YAML files using actionlint.
# Checks .github/workflows/*.yml for syntax errors, missing required fields,
# and common pitfalls.
#
# Non-blocking: warns but does not fail — actionlint may not be installed
# in all environments.
#
# Usage:
#   bash agent-flow/scripts/actionlint-check.sh [--project-root <path>]
#

set -euo pipefail

project_root="."

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: actionlint-check.sh [--project-root <path>]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

echo "=== GitHub Actions Workflow Validation (actionlint) ==="

# Find workflow files
workflow_dir="$project_root/.github/workflows"
if [ ! -d "$workflow_dir" ]; then
  echo "SKIP: No .github/workflows directory found at $workflow_dir"
  exit 0
fi

# Collect workflow files safely
wf_files=()
wf_count=0
for pattern in "$workflow_dir"/*.yml "$workflow_dir"/*.yaml; do
  [ -f "$pattern" ] && wf_files+=("$pattern") && wf_count=$((wf_count + 1)) || true
done

if [ "$wf_count" -eq 0 ]; then
  echo "SKIP: No workflow YAML files found in $workflow_dir"
  exit 0
fi

echo "Found $wf_count workflow file(s) in $workflow_dir"

# Check if actionlint is available
if ! command -v actionlint &>/dev/null; then
  echo "⚠️  actionlint not installed. Skipping validation."
  echo ""
  echo "  To install:"
  echo "    brew install actionlint                          # macOS"
  echo "    go install github.com/rhysd/actionlint/cmd/actionlint@latest  # Go"
  echo "    conda install -c conda-forge actionlint           # Conda"
  echo ""
  echo "actionlint-check skipped (tool not available)."
  exit 0
fi

# Run actionlint
issues=0
for wf in "${wf_files[@]}"; do
  [ -f "$wf" ] || continue
  wf_name="$(basename "$wf")"
  echo ""
  echo "--- $wf_name ---"

  result="$(actionlint --format='{{range $}}{{println .}}' "$wf" 2>&1)" || true
  if [ -n "$result" ]; then
    echo "$result"
    line_count="$(echo "$result" | wc -l | tr -d ' ')"
    issues=$((issues + line_count))
  else
    echo "  ✅ No issues found"
  fi
done

echo ""
echo "============================================"
echo "actionlint-check: $issues issue(s) found in $wf_count workflow file(s)."
echo ""
echo "  This check is advisory (non-blocking). Review warnings above."
echo "  To suppress specific rule warnings, add a comment:"
echo "    # actionlint-ignore: <rule-id>"
echo ""

exit 0
