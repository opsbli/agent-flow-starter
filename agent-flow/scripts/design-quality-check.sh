#!/usr/bin/env bash
#
# design-quality-check — agent-flow gate
#
# Checks DESIGN.md for quality indicators: reuse analysis completeness,
# evidence of existing abstraction review, and absence of placeholder values.
# Optional gate — outputs warnings for improvement opportunities.
#
# Usage:
#   bash agent-flow/scripts/design-quality-check.sh --change-dir <path>
#

set -euo pipefail

change_dir=""
project_root="."

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir) change_dir="$2"; shift 2 ;;
    --project-root|-ProjectRoot) project_root="$2"; shift 2 ;;
    -h|--help) echo "Usage: design-quality-check.sh --change-dir <path>"; exit 0 ;;
    *) echo "Unknown: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ] || [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2; exit 2
fi

design_file="$change_dir/DESIGN.md"
if [ ! -f "$design_file" ]; then
  echo "SKIP: No DESIGN.md in $change_dir"
  exit 0
fi

text="$(cat "$design_file")"
warnings=()

echo "=== Design Quality Check ==="

# 1. Reuse analysis
if ! echo "$text" | grep -Eiq '##\s*复用现有抽象|##\s*Reuse|##\s*reusable_abstractions|##\s*Existing Code Fit'; then
  warnings+=("DESIGN-QA: No reuse analysis section found.")
fi
if ! echo "$text" | grep -Eiq "##\s*不复用的原因|##\s*No.*Reuse|##\s*Don't Reuse"; then
  warnings+=("DESIGN-QA: No '不复用的原因' section found.")
fi

# 2. Standards reference
if ! echo "$text" | grep -Eiq 'standards_snapshot|docs/standards|code convention|编码规范|project standard'; then
  warnings+=("DESIGN-QA: No reference to project standards.")
fi

# 3. Placeholder values
placeholder_matches="$(echo "$text" | grep -oiE '\bpending\b|\bTBD\b|\bTODO\b|path/to|example|{.*?}' || true)"
if [ -n "$placeholder_matches" ]; then
  placeholder_count="$(printf '%s\n' "$placeholder_matches" | wc -l | tr -d ' ')"
else
  placeholder_count=0
fi
if [ "$placeholder_count" -gt 0 ]; then
  warnings+=("DESIGN-QA: $placeholder_count placeholder(s) found (pending/TBD/TODO).")
fi

# 4. Testing strategy
if ! echo "$text" | grep -Eiq '##\s*测试策略|##\s*Testing|##\s*Test Strategy'; then
  warnings+=("DESIGN-QA: No testing strategy section found.")
elif ! echo "$text" | grep -Eiq '\|.*AC-[0-9]+.*\|.*test|test.*\|.*AC-[0-9]+'; then
  warnings+=("DESIGN-QA: Testing strategy present but no AC-to-test mappings found.")
fi

# Output
echo ""
echo "============================================"
if [ "${#warnings[@]}" -gt 0 ]; then
  echo "Design quality check found ${#warnings[@]} suggestion(s):"
  for w in "${warnings[@]}"; do echo " - $w"; done
  echo ""
  echo "NOTE: This is a non-blocking quality advisory."
  exit 0
fi

echo "Design quality check passed. No quality concerns detected."
