#!/usr/bin/env bash
# Detect unused agent-flow scripts, templates, and knowledge files
# Usage: bash agent-flow/scripts/detect-unused.sh [--project-root <path>]
set -euo pipefail
project_root="${1:-.}"
af_dir="$project_root/agent-flow"
echo "=== agent-flow Cleanup Scan ==="
found=0
# Scripts
go_file="$af_dir/GO.md"
go_content=""
[ -f "$go_file" ] && go_content=$(cat "$go_file" 2>/dev/null)
change_content=""
[ -d "$af_dir/changes" ] && change_content=$(find "$af_dir/changes" -name '*.md' -exec cat {} \; 2>/dev/null)
scripts_dir="$af_dir/scripts"
if [ -d "$scripts_dir" ]; then
  for f in "$scripts_dir"/*.sh "$scripts_dir"/*.ps1; do
    [ ! -f "$f" ] && continue
    name=$(basename "$f")
    # Skip core scripts
    echo "$name" | grep -qE '^(install-agent-flow|scaffold-health|init-project|manifest-check|check-change)' && continue
    # Check if referenced
    if echo "$go_content$change_content" | grep -qF "$name"; then
      : # referenced
    else
      echo "  [Script] $name: UNUSED — never referenced in GO.md or change artifacts"
      found=$((found + 1))
    fi
  done
fi
# Templates
tpl_dir="$af_dir/templates"
if [ -d "$tpl_dir" ]; then
  for f in "$tpl_dir"/*.md; do
    [ ! -f "$f" ] && continue
    name=$(basename "$f")
    echo "$name" | grep -qE '^(AGENTS|STATE|CHANGE|CODE_SCAN|DESIGN|TASKS|VERIFY|REPORT|REQUIREMENT|EVOLUTION|PLAN|AUDIT|REVIEW)' && continue
    if echo "$go_content$change_content" | grep -qF "$name"; then
      : # referenced
    else
      echo "  [Template] $name: UNUSED — never referenced"
      found=$((found + 1))
    fi
  done
fi
# Knowledge: check for empty files
knowledge_dir="$af_dir/knowledge"
if [ -d "$knowledge_dir" ]; then
  for f in "$knowledge_dir"/*.md; do
    [ ! -f "$f" ] && continue
    name=$(basename "$f")
    [ "$name" = ".gitkeep" ] && continue
    lines=$(wc -l < "$f" 2>/dev/null || echo 0)
    [ "$lines" -le 3 ] && echo "  [Knowledge] $name: EMPTY — only $lines lines" && found=$((found + 1))
  done
fi
if [ "$found" -eq 0 ]; then
  echo "  No unused files detected."
else
  echo ""
  echo "Suggested: review UNUSED files and archive or delete them"
fi
