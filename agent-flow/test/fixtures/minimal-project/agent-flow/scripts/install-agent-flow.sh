#!/usr/bin/env bash
# Install or upgrade agent-flow scaffold into a target project.
#
# Usage:
#   bash agent-flow/scripts/install-agent-flow.sh --target /path/to/project
#   bash agent-flow/scripts/install-agent-flow.sh --target /path/to/project --starter-root /path/to/starter --force
#
# Starter-owned files (overwritten): core/, flows/, templates/, scripts/, README.md, UPGRADE.md, VERSION, ADVANTAGES.md, GO.md, manifest.yaml
# Project-owned files (preserved): changes/, logs/, reports/, knowledge/, decisions/

set -euo pipefail

# --- Defaults ---
target=""
starter_root=""
force=false

# --- Parse arguments ---
while [ "$#" -gt 0 ]; do
  case "$1" in
    --target|-Target)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      target="$2"; shift 2 ;;
    --starter-root)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      starter_root="$2"; shift 2 ;;
    --force|-Force)
      force=true; shift ;;
    -h|--help)
      echo "Usage: $0 --target <project-root> [--starter-root <starter-root>] [--force]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$target" ]; then
  echo "ERROR: --target is required" >&2
  exit 2
fi

# --- Resolve paths ---
script_dir="$(cd "$(dirname "$0")" && pwd)"
if [ -z "$starter_root" ]; then
  starter_root="$(cd "$script_dir/.." && pwd)"
fi

target="$(cd "$target" && pwd)"
starter_root="$(cd "$starter_root" && pwd)"

if [ ! -d "$starter_root/agent-flow" ]; then
  echo "ERROR: Starter root does not contain agent-flow/: $starter_root" >&2
  exit 2
fi

target_af="$target/agent-flow"
source_af="$starter_root/agent-flow"

echo "Installing agent-flow from: $source_af"
echo "Target project: $target"
echo ""

# --- Starter-owned files ---
starter_owned=(
  "core"
  "flows"
  "templates"
  "scripts"
  "README.md"
  "UPGRADE.md"
  "VERSION"
  "ADVANTAGES.md"
  "GO.md"
  "manifest.yaml"
)

# --- Project-owned files ---
project_owned=(
  "changes"
  "logs"
  "reports"
  "knowledge"
  "decisions"
)

# --- Ensure target agent-flow/ exists ---
mkdir -p "$target_af"

# --- Helper: copy a directory recursively ---
copy_dir() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
  find "$src" -type f | while IFS= read -r f; do
    local rel="${f#$src/}"
    local dest_file="$dst/$rel"
    mkdir -p "$(dirname "$dest_file")"
    cp "$f" "$dest_file"
  done
}

# --- Merge manifest.yaml ---
merge_manifest() {
  local src="$1" dst="$2"
  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    echo "  Created manifest.yaml (new)"
    return
  fi

  if [ "$force" = false ]; then
    local todo_count
    todo_count=$(grep -c "TODO_" "$dst" 2>/dev/null || echo 0)
    if [ "$todo_count" -gt 0 ]; then
      echo "  WARNING: manifest.yaml has $todo_count unresolved TODO_ values."
      echo "  Re-run init-project.sh after install to resolve them."
    fi
    echo "  Preserving existing manifest.yaml (use --force to overwrite)"
    return
  fi

  cp "$src" "$dst"
  echo "  Overwrote manifest.yaml (--force)"
}

# --- Copy starter-owned files ---
echo ""
echo "=== Installing starter-owned files ==="
for item in "${starter_owned[@]}"; do
  src="$source_af/$item"
  dst="$target_af/$item"

  if [ ! -e "$src" ]; then
    echo "  SKIP (not found): $item"
    continue
  fi

  if [ "$item" = "manifest.yaml" ]; then
    merge_manifest "$src" "$dst"
    continue
  fi

  if [ -d "$src" ]; then
    copy_dir "$src" "$dst"
    echo "  UPDATED: $item/"
  else
    cp "$src" "$dst"
    echo "  UPDATED: $item"
  fi
done

# --- Preserve project-owned files ---
echo ""
echo "=== Preserving project-owned files ==="
for item in "${project_owned[@]}"; do
  path="$target_af/$item"
  if [ -d "$path" ]; then
    echo "  PRESERVED: $item/"
  else
    mkdir -p "$path"
    gitkeep="$path/.gitkeep"
    [ ! -f "$gitkeep" ] && touch "$gitkeep"
    echo "  CREATED: $item/"
  fi
done

# --- AGENTS.md block ---
echo ""
echo "=== AGENTS.md ==="
agents_md="$target/AGENTS.md"
agents_template="$source_af/templates/AGENTS.md"

if [ -f "$agents_md" ]; then
  if grep -q "<!-- agent-flow:start -->" "$agents_md" 2>/dev/null; then
    echo "  AGENTS.md already has agent-flow block (preserved)"
  else
    echo "" >> "$agents_md"
    cat "$agents_template" >> "$agents_md"
    echo "  Appended agent-flow block to AGENTS.md"
  fi
else
  cp "$agents_template" "$agents_md"
  echo "  Created AGENTS.md from template"
fi

# --- Done ---
echo ""
echo "=== Install complete ==="
echo "From: $source_af"
echo "To:   $target_af"
echo ""
echo "Next steps:"
echo "  cd $target"
echo "  bash agent-flow/scripts/scaffold-health.sh"
echo "  bash agent-flow/scripts/init-project.sh"
echo ""
echo "If you customized starter-owned files (core/, flows/, etc.),"
echo "record those decisions in agent-flow/decisions/ before re-running install."
