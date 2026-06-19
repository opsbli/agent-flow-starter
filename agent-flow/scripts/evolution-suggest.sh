#!/usr/bin/env bash
# Generate improvement suggestions and auto-fill EVOLUTION.md drafts
# Usage:
#   bash agent-flow/scripts/evolution-suggest.sh --change-dir <change-dir> [--output <file>]
#   bash agent-flow/scripts/evolution-suggest.sh [--project-root <path>]
set -euo pipefail

change_dir=""
project_root="."
output_file=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    --output|-Output)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      output_file="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 --change-dir <change-dir> [--output <file>]"
      echo "       $0 [--project-root <path>]"
      exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/_common.sh"

# --- Mode 1: Change-specific analysis ---
if [ -n "$change_dir" ]; then
  [ -d "$change_dir" ] || { echo "ChangeDir not found: $change_dir" >&2; exit 2; }

  flow="$(flow_level "$change_dir")"
  change_name="$(basename "$change_dir")"
  problems=""
  knowledge_suggestions=""
  adr_suggestions=""
  gate_suggestions=""
  template_suggestions=""
  no_change_reason=""

  # 1. Scan REQUIREMENT.md for new terms
  req_file="$change_dir/REQUIREMENT.md"
  if [ -f "$req_file" ]; then
    terms=$(awk '/^## 术语/{found=1; next} /^## / && found {found=0} found && /^\|/' "$req_file" 2>/dev/null | grep -v "是否已沉淀" | grep -v "术语.*定义" || true)
    if [ -n "$terms" ]; then
      new_terms=$(echo "$terms" | while IFS='|' read -r _ term _ _ deposited; do
        term="$(echo "$term" | xargs)"
        deposited="$(echo "$deposited" | xargs)"
        [ -n "$term" ] && [ "$deposited" != "是" ] && [ "$deposited" != "是，" ] && echo "$term"
      done)
      if [ -n "$new_terms" ]; then
        knowledge_suggestions="New terms from requirements that are not yet in glossary: $(echo "$new_terms" | tr '\n' ', ' | sed 's/, $//')"
        problems="${problems}- Requirements introduced new terminology without glossary deposition.\n"
      fi
    fi
  fi

  # 2. Scan CODE_SCAN.md for patterns and potential pitfalls
  scan_file="$change_dir/CODE_SCAN.md"
  if [ -f "$scan_file" ]; then
    reusable=$(grep -i "reusable" "$scan_file" | grep -vi "none" | head -3 || true)
    if [ -n "$reusable" ]; then
      [ -n "$knowledge_suggestions" ] && knowledge_suggestions="${knowledge_suggestions}; "
      knowledge_suggestions="${knowledge_suggestions}Reusable abstractions found — consider updating reuse-map.md"
    fi
    standards=$(grep -i "standards_snapshot\|冲突\|缺口" "$scan_file" | grep -vi "none\|无" | head -3 || true)
    if [ -n "$standards" ]; then
      problems="${problems}- Standards gaps or conflicts recorded in CODE_SCAN.\n"
    fi
  fi

  # 3. Check DESIGN.md for ADR candidates
  design_file="$change_dir/DESIGN.md"
  if [ -f "$design_file" ]; then
    adr_candidates=$(awk '/^## ADR 候选/{found=1; next} /^## / && found {found=0} found' "$design_file" 2>/dev/null | grep -vi "none\|无" || true)
    if [ -n "$adr_candidates" ]; then
      adr_suggestions="ADR candidates found in DESIGN.md — consider creating ADR entries for irreversible decisions."
    fi
  fi

  # 4. Check if change involved protected areas that need gate improvements
  change_file="$change_dir/CHANGE.md"
  if [ -f "$change_file" ]; then
    if grep -qi "schema\|database\|migration" "$change_file" 2>/dev/null; then
      gate_suggestions="Schema change detected — verify db-migration-check gate coverage is adequate."
    fi
    if grep -qi "permission\|auth\|role" "$change_file" 2>/dev/null; then
      [ -n "$gate_suggestions" ] && gate_suggestions="${gate_suggestions}; "
      gate_suggestions="${gate_suggestions}Auth/permission change — verify api-compatibility-check coverage."
    fi
    if grep -qi "state.machine\|workflow\|status" "$change_file" 2>/dev/null; then
      [ -n "$gate_suggestions" ] && gate_suggestions="${gate_suggestions}; "
      gate_suggestions="${gate_suggestions}State machine change — verify code-drift-check status section coverage."
    fi
  fi

  # 5. Check if the flow ran as expected
  if [ "$flow" = "Light" ]; then
    template_suggestions="Light change completed — verify that minimum artifacts (STATE, CHANGE, CODE_SCAN, VERIFY, REPORT) were sufficient."
  elif [ "$flow" = "Heavy" ]; then
    # Check if all Heavy artifacts exist
    for art in PLAN.md AUDIT.md REVIEW.md; do
      [ ! -f "$change_dir/$art" ] && problems="${problems}- Heavy change missing required artifact: $art\n"
    done
  fi

  # Default no_change_reason
  if [ -z "$problems" ] && [ -z "$knowledge_suggestions" ] && [ -z "$adr_suggestions" ] && [ -z "$gate_suggestions" ] && [ -z "$template_suggestions" ]; then
    no_change_reason="No issues or improvement opportunities detected for this change."
  fi

  # --- Build EVOLUTION.md draft ---
  output="# Evolution

## Machine Check

$(echo -e "problem: $(echo "$problems" | head -1 | sed 's/- //' | xargs || echo none)")
knowledge: $(echo "$knowledge_suggestions" | head -1 | sed 's/:.*//' | xargs || echo none)
adr: $(echo "$adr_suggestions" | head -1 | sed 's/:.*//' | xargs || echo none)
gate: $(echo "$gate_suggestions" | head -1 | sed 's/:.*//' | xargs || echo none)
template: $(echo "$template_suggestions" | head -1 | sed 's/:.*//' | xargs || echo none)
no_change_reason: $(echo "$no_change_reason" | xargs || echo none)

## 本次 change 暴露的问题

$(echo -e "${problems:-无}")

## 应写入 knowledge 的内容

$(if [ -n "$knowledge_suggestions" ]; then echo "- ${knowledge_suggestions}"; else echo "- 无"; fi)

## 应新增或修改的 ADR

$(if [ -n "$adr_suggestions" ]; then echo "- ${adr_suggestions}"; else echo "- 无"; fi)

## 应新增的 gate

$(if [ -n "$gate_suggestions" ]; then echo "- ${gate_suggestions}"; else echo "- 无"; fi)

## 应调整的模板

$(if [ -n "$template_suggestions" ]; then echo "- ${template_suggestions}"; else echo "- 无"; fi)

## Improvement Tracker 更新

- [ ] 不需要跟踪，原因：
- [ ] 已新增或更新 \`agent-flow/knowledge/improvement-tracker.md\`

## 本次不调整的原因

${no_change_reason:-无}
"

  if [ -n "$output_file" ]; then
    echo -e "$output" > "$output_file"
    echo "Wrote EVOLUTION.md draft to: $output_file"
  else
    echo -e "$output"
  fi

  exit 0
fi

# --- Mode 2: Project-wide suggestions (original behavior, enhanced) ---
af_dir="$project_root/agent-flow"
changes_dir="$af_dir/changes"

total=0; completed=0
if [ -d "$changes_dir" ]; then
  for d in "$changes_dir"/*/; do
    [ "$(basename "$d")" = ".gitkeep" ] && continue
    [ ! -d "$d" ] && continue
    total=$((total + 1))
    [ -f "$d/REPORT.md" ] && completed=$((completed + 1))
  done
fi

k_count=0
[ -d "$af_dir/knowledge" ] && k_count=$(find "$af_dir/knowledge" -maxdepth 1 -type f ! -name '.gitkeep' 2>/dev/null | wc -l)
adr_count=0
[ -d "$af_dir/decisions" ] && adr_count=$(find "$af_dir/decisions" -name 'ADR-*' 2>/dev/null | wc -l)
gate_count=0
[ -f "$af_dir/rules/gates.txt" ] && gate_count=$(grep -cEv '^[[:space:]]*(#|$)' "$af_dir/rules/gates.txt" 2>/dev/null || echo 0)

suggestions=""
[ "$total" -gt 0 ] && [ "$completed" -eq 0 ] && suggestions="$suggestions\n- [HIGH] [Process] No completed changes yet. Start with a small task to validate the workflow."
[ "$k_count" -le 2 ] && [ "$total" -gt 0 ] && suggestions="$suggestions\n- [MEDIUM] [Knowledge] Only $k_count knowledge files for $total changes. Add glossary.md, pitfalls.md, and module-map.md."
[ "$adr_count" -eq 0 ] && [ "$total" -gt 2 ] && suggestions="$suggestions\n- [MEDIUM] [Decisions] No ADRs recorded. Document architecture decisions as they're made."
[ "$total" -gt 3 ] && [ "$k_count" -lt 3 ] && suggestions="$suggestions\n- [LOW] [Knowledge] $k_count knowledge files for $total changes. Consider expanding."
[ -z "$suggestions" ] && suggestions="\nNo suggestions at this time. Project is in good shape."

cat << SUGGESTEOF
# Evolution Suggestions

Generated: $(date '+%Y-%m-%d %H:%M')

## Summary

| Metric | Value |
|--------|-------|
| Total Changes | $total |
| Completed | $completed |
| Knowledge Files | $k_count |
| ADRs | $adr_count |
| Gate Scripts | $gate_count |

## Improvement Suggestions
$(echo -e "$suggestions")

---
*Generated by evolution-suggest.sh — use --change-dir <path> for change-specific EVOLUTION.md drafting*
SUGGESTEOF
