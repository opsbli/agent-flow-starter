#!/usr/bin/env bash
# Generate an ADR file and update the INDEX.md.
# Usage:
#   bash agent-flow/scripts/generate-adr.sh --title "ADR title" [--status Proposed] [--supersedes ADR-NNNN] [--change-dir <change-dir>]
set -euo pipefail

title=""
status="Proposed"
supersedes=""
change_dir=""
decisions_root="agent-flow/decisions"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --title|-Title)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      title="$2"; shift 2 ;;
    --status|-Status)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      status="$2"; shift 2 ;;
    --supersedes|-Supersedes)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      supersedes="$2"; shift 2 ;;
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    --decisions-root|-DecisionsRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      decisions_root="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 --title <title> [--status Proposed|Accepted] [--supersedes ADR-NNNN] [--change-dir <change-dir>]"
      echo ""
      echo "Creates a new ADR file in <decisions-root>/ and updates INDEX.md."
      echo "If --change-dir is given, reads DESIGN.md's ADR 候选 section for context."
      exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

# --- Validate ---
if [ -z "$title" ]; then
  echo "ERROR: --title is required" >&2
  exit 2
fi

case "$status" in
  Proposed|Accepted|Deprecated|Superseded) ;;
  *) echo "ERROR: --status must be Proposed, Accepted, Deprecated, or Superseded" >&2; exit 2 ;;
esac

# --- Determine next ADR number ---
mkdir -p "$decisions_root"
max_num=0
for f in "$decisions_root"/ADR-*.md; do
  [ -f "$f" ] || continue
  num=$(basename "$f" | sed 's/ADR-0*//;s/-.*//')
  [ "$num" -gt "$max_num" ] 2>/dev/null && max_num=$num
done
next_num=$((max_num + 1))
adr_id=$(printf "ADR-%04d" "$next_num")

# --- Slug for filename ---
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]+/-/g; s/^-//; s/-$//' 2>/dev/null || echo "untitled")
[ -n "$slug" ] || slug="untitled"
adr_file="$decisions_root/${adr_id}-${slug}.md"

if [ -f "$adr_file" ]; then
  echo "ERROR: ADR file already exists: $adr_file" >&2
  exit 2
fi

# --- Extract context from change_dir if given ---
background=""
decision=""
alternatives=""
tradeoffs=""

if [ -n "$change_dir" ] && [ -f "$change_dir/DESIGN.md" ]; then
  design_text=$(cat "$change_dir/DESIGN.md")
  # Extract ADR 候选 section
  adr_section=$(echo "$design_text" | sed -n '/^## ADR 候选/,/^## /p' | head -n -1 || true)
  if [ -n "$adr_section" ] && ! echo "$adr_section" | grep -qi "none\|无"; then
    background="$adr_section"
  fi
fi

# --- Create ADR file ---
cat > "$adr_file" << ADREOF
# $adr_id: $title

## 状态

$status

## Supersedes

${supersedes:-none}

## Superseded By

none

## 背景

$(if [ -n "$background" ]; then echo "$background"; else echo "TBD — describe the context that led to this decision."; fi)

## 决策

TBD — describe the chosen approach.

## 备选方案

TBD — list alternatives that were considered.

## 取舍

TBD — explain the trade-offs.

## 后果

TBD — describe the consequences of this decision.

## 触发 change

${change_dir:-TBD}

## 日期

$(date '+%Y-%m-%d')

## 索引维护

- [ ] 已更新 \`$decisions_root/INDEX.md\`
- [ ] Status / Supersedes / Superseded By 与索引一致
ADREOF

echo "Created: $adr_file"

# --- Update INDEX.md ---
index_file="$decisions_root/INDEX.md"
if [ -f "$index_file" ]; then
  # Find the index table and add a new row
  # Insert after the last ADR row (or after the header)
  if grep -q "^| ADR-" "$index_file"; then
    # Insert before the closing empty line after the table
    sed -i "/^| ADR-/a\\
| $adr_id | $title | $status | ${supersedes:-none} | none | ${change_dir:-TBD} | $(date '+%Y-%m-%d') |" "$index_file"
  else
    # No ADR rows yet, add after table header
    sed -i "/^|---|---|---|---|---|---|---|/a\\
| $adr_id | $title | $status | ${supersedes:-none} | none | ${change_dir:-TBD} | $(date '+%Y-%m-%d') |" "$index_file"
  fi
  echo "Updated: $index_file"
else
  echo "WARNING: INDEX.md not found at $index_file. Create it manually."
fi

echo ""
echo "ADR $adr_id created successfully."
