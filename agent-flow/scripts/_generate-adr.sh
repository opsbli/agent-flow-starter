#!/usr/bin/env bash
# Generate an ADR file and update the INDEX.md.
# Usage:
#   bash agent-flow/scripts/_generate-adr.sh --title "title" [--status Proposed] [--change-dir <dir>]
#   bash agent-flow/scripts/_generate-adr.sh --scan-all [--changes-root <dir>]
set -euo pipefail

title=""
status="Proposed"
supersedes=""
change_dir=""
decisions_root="agent-flow/decisions"
scan_all=false
changes_root="agent-flow/changes"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --title|-Title) title="$2"; shift 2 ;;
    --status|-Status) status="$2"; shift 2 ;;
    --supersedes|-Supersedes) supersedes="$2"; shift 2 ;;
    --change-dir|-ChangeDir) change_dir="$2"; shift 2 ;;
    --scan-all|-ScanAll) scan_all=true; shift ;;
    --changes-root|-ChangesRoot) changes_root="$2"; shift 2 ;;
    --decisions-root|-DecisionsRoot) decisions_root="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 --title <title> [--status Proposed|Accepted] [--change-dir <dir>]"
      echo "       $0 --scan-all [--changes-root <dir>]"
      echo "Scans all DESIGN.md files for ADR candidate sections."
      exit 0 ;;
    *) echo "Unknown: $1" >&2; exit 2 ;;
  esac
done

# --- Scan-all mode ---
if [ "$scan_all" = true ]; then
  echo "Scanning for ADR candidates in: $changes_root"
  found=0
  for d in "$changes_root"/*/; do
    [ -d "$d" ] || continue
    [ "$(basename "$d")" = ".gitkeep" ] && continue
    design="$d/DESIGN.md"
    [ ! -f "$design" ] && continue
    section=$(sed -n '/^## ADR 候选/,/^## /p' "$design" 2>/dev/null | head -n -1 || true)
    if [ -n "$section" ] && ! echo "$section" | grep -qi "none\|无"; then
      name=$(basename "$d")
      echo ""
      echo "--- ADR candidate in $name ---"
      echo "$section" | head -5
      echo "  -> Use: --change-dir $d --title \"...\""
      found=$((found + 1))
    fi
  done
  echo ""
  echo "Scan complete. $found ADR candidate(s) found."
  exit 0
fi

# --- Validate ---
[ -n "$title" ] || { echo "ERROR: --title is required" >&2; exit 2; }
case "$status" in Proposed|Accepted|Deprecated|Superseded) ;; *) echo "ERROR: invalid --status" >&2; exit 2 ;; esac

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

slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\+/-/g; s/^-//; s/-$//')
[ -n "$slug" ] || slug="untitled"
adr_file="$decisions_root/${adr_id}-${slug}.md"
[ -f "$adr_file" ] && { echo "ERROR: ADR exists: $adr_file" >&2; exit 2; }

# --- Extract context from change_dir ---
background=""
if [ -n "$change_dir" ] && [ -f "$change_dir/DESIGN.md" ]; then
  section=$(sed -n '/^## ADR 候选/,/^## /p' "$change_dir/DESIGN.md" 2>/dev/null | head -n -1 || true)
  if [ -n "$section" ] && ! echo "$section" | grep -qi "none\|无"; then
    background="$section"
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

$(if [ -n "$background" ]; then echo "$background"; else echo "TBD — describe the context."; fi)

## 决策

TBD

## 备选方案

TBD

## 取舍

TBD

## 后果

TBD

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
  if grep -q "^| ADR-" "$index_file"; then
    sed -i "/^| ADR-/a\\
| $adr_id | $title | $status | ${supersedes:-none} | none | ${change_dir:-TBD} | $(date '+%Y-%m-%d') |" "$index_file"
  else
    sed -i "/^|---|---/a\\
| $adr_id | $title | $status | ${supersedes:-none} | none | ${change_dir:-TBD} | $(date '+%Y-%m-%d') |" "$index_file"
  fi
  echo "Updated: $index_file"
else
  echo "WARNING: INDEX.md not found."
fi

echo "ADR $adr_id created successfully."
