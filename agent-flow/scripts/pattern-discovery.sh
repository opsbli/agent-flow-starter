#!/usr/bin/env bash
# Discover recurring patterns across EVOLUTION.md files and cross-reference with pitfalls.md.
# Usage: bash agent-flow/scripts/pattern-discovery.sh [--min-occurrences 2] [--output report.md]

set -euo pipefail

CHANGES_ROOT="agent-flow/changes"
MIN_OCCURRENCES=2
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --changes-root) CHANGES_ROOT="$2"; shift 2 ;;
    --min-occurrences) MIN_OCCURRENCES="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHANGES_DIR="$ROOT/$CHANGES_ROOT"
KNOWLEDGE_DIR="$ROOT/agent-flow/knowledge"

[ -d "$CHANGES_DIR" ] || { echo "No changes directory found"; exit 0; }

# ── Pattern definitions ──
declare -A PATTERN_CATEGORY
PATTERN_CATEGORY["documentation_gap"]="knowledge"
PATTERN_CATEGORY["test_coverage_gap"]="gate"
PATTERN_CATEGORY["boundary_violation"]="gate"
PATTERN_CATEGORY["schema_risk"]="audit"
PATTERN_CATEGORY["permission_risk"]="audit"
PATTERN_CATEGORY["api_contract_break"]="gate"
PATTERN_CATEGORY["state_machine_complexity"]="design"
PATTERN_CATEGORY["knowledge_not_captured"]="knowledge"
PATTERN_CATEGORY["template_gap"]="process"
PATTERN_CATEGORY["process_bypass"]="process"

# ── Scan EVOLUTION.md files ──
declare -A PATTERN_COUNTS
declare -A PATTERN_CHANGES
CHANGES_SCANNED=0
EVO_FOUND=0

for change_dir in "$CHANGES_DIR"/*/; do
  [ ! -d "$change_dir" ] && continue
  CHANGES_SCANNED=$((CHANGES_SCANNED + 1))

  evo_file="$change_dir/EVOLUTION.md"
  [ ! -f "$evo_file" ] && continue
  EVO_FOUND=$((EVO_FOUND + 1))

  change_id="$(basename "$change_dir")"
  evo_text="$(cat "$evo_file")"

  # Check each pattern
  echo "$evo_text" | grep -qi "文档\|documentation\|缺文档\|缺注释\|missing doc\|unclear" && {
    PATTERN_COUNTS["documentation_gap"]=$((PATTERN_COUNTS["documentation_gap"] + 1))
    PATTERN_CHANGES["documentation_gap"]="${PATTERN_CHANGES["documentation_gap"]} $change_id"
  } || true

  echo "$evo_text" | grep -qi "测试覆盖\|test coverage\|缺测试\|缺少测试\|untested\|no test" && {
    PATTERN_COUNTS["test_coverage_gap"]=$((PATTERN_COUNTS["test_coverage_gap"] + 1))
    PATTERN_CHANGES["test_coverage_gap"]="${PATTERN_CHANGES["test_coverage_gap"]} $change_id"
  } || true

  echo "$evo_text" | grep -qi "越界\|越权\|边界\|boundary\|超出范围\|write_files\|unauthorized" && {
    PATTERN_COUNTS["boundary_violation"]=$((PATTERN_COUNTS["boundary_violation"] + 1))
    PATTERN_CHANGES["boundary_violation"]="${PATTERN_CHANGES["boundary_violation"]} $change_id"
  } || true

  echo "$evo_text" | grep -qi "schema\|迁移\|migration\|数据库\|database\|数据模型" && {
    PATTERN_COUNTS["schema_risk"]=$((PATTERN_COUNTS["schema_risk"] + 1))
    PATTERN_CHANGES["schema_risk"]="${PATTERN_CHANGES["schema_risk"]} $change_id"
  } || true

  echo "$evo_text" | grep -qi "权限\|permission\|auth\|认证\|角色\|role\|匿名" && {
    PATTERN_COUNTS["permission_risk"]=$((PATTERN_COUNTS["permission_risk"] + 1))
    PATTERN_CHANGES["permission_risk"]="${PATTERN_CHANGES["permission_risk"]} $change_id"
  } || true

  echo "$evo_text" | grep -qi "API\|接口\|contract\|契约\|破坏性\|breaking" && {
    PATTERN_COUNTS["api_contract_break"]=$((PATTERN_COUNTS["api_contract_break"] + 1))
    PATTERN_CHANGES["api_contract_break"]="${PATTERN_CHANGES["api_contract_break"]} $change_id"
  } || true

  echo "$evo_text" | grep -qi "状态机\|state machine\|工作流\|workflow\|状态流转" && {
    PATTERN_COUNTS["state_machine_complexity"]=$((PATTERN_COUNTS["state_machine_complexity"] + 1))
    PATTERN_CHANGES["state_machine_complexity"]="${PATTERN_CHANGES["state_machine_complexity"]} $change_id"
  } || true

  echo "$evo_text" | grep -qi "知识\|knowledge\|沉淀\|术语\|glossary\|坑点\|pitfall" && {
    PATTERN_COUNTS["knowledge_not_captured"]=$((PATTERN_COUNTS["knowledge_not_captured"] + 1))
    PATTERN_CHANGES["knowledge_not_captured"]="${PATTERN_CHANGES["knowledge_not_captured"]} $change_id"
  } || true

  echo "$evo_text" | grep -qi "模板\|template\|缺少字段\|missing field\|artifact" && {
    PATTERN_COUNTS["template_gap"]=$((PATTERN_COUNTS["template_gap"] + 1))
    PATTERN_CHANGES["template_gap"]="${PATTERN_CHANGES["template_gap"]} $change_id"
  } || true

  echo "$evo_text" | grep -qi "跳过\|bypass\|绕过\|跳过流程\|形式主义" && {
    PATTERN_COUNTS["process_bypass"]=$((PATTERN_COUNTS["process_bypass"] + 1))
    PATTERN_CHANGES["process_bypass"]="${PATTERN_CHANGES["process_bypass"]} $change_id"
  } || true
done

# ── Read existing pitfalls ──
EXISTING_PITFALLS=""
PITFALLS_FILE="$KNOWLEDGE_DIR/pitfalls.md"
[ -f "$PITFALLS_FILE" ] && EXISTING_PITFALLS="$(grep -E '^### ' "$PITFALLS_FILE" || true)"

# ── Build report ──
REPORT="# Pattern Discovery Report

Generated: $(date '+%Y-%m-%d %H:%M')
Min occurrences to flag: $MIN_OCCURRENCES
Changes scanned: $CHANGES_SCANNED
EVOLUTION.md files found: $EVO_FOUND

"

ALL_PATTERNS=""
RECURRING_PATTERNS=""
MISSING_PITFALLS=""
HAS_RECURRING=false
HAS_MISSING=false

for pattern in documentation_gap test_coverage_gap boundary_violation schema_risk permission_risk api_contract_break state_machine_complexity knowledge_not_captured template_gap process_bypass; do
  count="${PATTERN_COUNTS[$pattern]:-0}"
  [ "$count" -eq 0 ] && continue

  cat="${PATTERN_CATEGORY[$pattern]}"
  changes="$(echo "${PATTERN_CHANGES[$pattern]:-}" | tr ' ' '\n' | sort -u | tr '\n' ', ' | sed 's/,$//')"

  if [ "$count" -ge "$MIN_OCCURRENCES" ]; then
    ALL_PATTERNS="$ALL_PATTERNS| **$pattern** | $cat | **$count** | $changes |\n"
    HAS_RECURRING=true

    # Check if already in pitfalls
    IN_PITFALLS=false
    if echo "$EXISTING_PITFALLS" | grep -qi "$pattern"; then
      IN_PITFALLS=true
    fi

    if [ "$IN_PITFALLS" = false ]; then
      MISSING_PITFALLS="$MISSING_PITFALLS| $pattern | $count | $cat | $changes | Add to pitfalls.md |\n"
      HAS_MISSING=true

      suggestion="Consider documenting in knowledge/"
      case "$cat" in
        knowledge) suggestion="Consider adding to \`pitfalls.md\` or \`glossary.md\`";;
        gate) suggestion="Consider adding a new gate script or enhancing existing checks";;
        audit) suggestion="Consider adding to audit checklist in \`AUDIT.md\` template";;
        design) suggestion="Consider adding to \`DESIGN.md\` template or design-check rules";;
        process) suggestion="Consider updating flow rules in \`GO.md\` or flow files";;
      esac

      RECURRING_PATTERNS="$RECURRING_PATTERNS
### $pattern ($count times)

- **Category**: $cat
- **Affected changes**: $changes
- **Suggestion**: $suggestion
"
    fi
  else
    ALL_PATTERNS="$ALL_PATTERNS| $pattern | $cat | $count | $changes |\n"
  fi
done

if [ -z "$ALL_PATTERNS" ]; then
  REPORT="$REPORT
## No Patterns Detected

No EVOLUTION.md files found or no patterns matched.
"
else
  REPORT="$REPORT
## All Detected Patterns

| Pattern | Category | Occurrences | Affected Changes |
|---------|----------|-------------|------------------|
$(echo -e "$ALL_PATTERNS")
"
fi

if [ "$HAS_RECURRING" = true ]; then
  REPORT="$REPORT
## ⚠️ Recurring Patterns (>= $MIN_OCCURRENCES occurrences)
$RECURRING_PATTERNS
"
fi

if [ "$HAS_MISSING" = true ]; then
  REPORT="$REPORT
## 📝 Candidates for pitfalls.md

These recurring patterns are not yet captured in \`pitfalls.md\`:

| Pattern | Occurrences | Category | Example Changes | Suggested Entry |
|---------|-------------|----------|-----------------|-----------------|
$(echo -e "$MISSING_PITFALLS")
"
fi

REPORT="$REPORT
---
*Generated by pattern-discovery.sh*
"

if [ -n "$OUTPUT" ]; then
  echo -e "$REPORT" > "$OUTPUT"
  echo "Report written to: $OUTPUT"
else
  echo -e "$REPORT"
fi
