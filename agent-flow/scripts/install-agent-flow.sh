#!/usr/bin/env bash
# Install or upgrade agent-flow scaffold into a target project.
#
# Usage:
#   bash agent-flow/scripts/install-agent-flow.sh --target /path/to/project
#   bash agent-flow/scripts/install-agent-flow.sh --target /path/to/project --starter-root /path/to/starter --force
#
# Starter-owned files (overwritten): core/, flows/, templates/, scripts/, rules/, test/, README.md, UPGRADE.md, VERSION, ADVANTAGES.md, GO.md, manifest.yaml
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
  "rules"
  "test"
  "README.md"
  "FAQ.md"
  "READING.md"
  "UPGRADE.md"
  "CHANGELOG.md"
  "VERSION"
  "ADVANTAGES.md"
  "GO.md"
  "project-profiles.json"
  "manifest.yaml"
  "ecc-integration.md"
)

# --- Project-owned files ---
project_owned=(
  "changes"
  "logs"
  "reports"
  "knowledge"
  "decisions"
)

# History directories are project-owned runtime evidence. New target projects
# should get clean directories only; starter-local ignored histories must never
# be distributed into business projects.
history_owned=(
  "changes"
  "logs"
  "reports"
)

is_history_owned() {
  local item="$1"
  local candidate
  for candidate in "${history_owned[@]}"; do
    if [ "$candidate" = "$item" ]; then
      return 0
    fi
  done
  return 1
}

# --- Ensure target agent-flow/ exists ---
mkdir -p "$target_af"

# --- Helper: copy a directory recursively ---
copy_dir() {
  local src="$1" dst="$2"
  local exclude_fixtures="${3:-false}"
  mkdir -p "$dst"
  if [ "$exclude_fixtures" = true ]; then
    find "$src" -type f ! -path "$src/fixtures/*"
  else
    find "$src" -type f
  fi | while IFS= read -r f; do
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
    if is_history_owned "$item"; then
      [ ! -f "$path/.gitkeep" ] && touch "$path/.gitkeep"
      echo "  PRESERVED: $item/ (history directory; no starter files seeded)"
      continue
    fi

    seeded_count=0
    if [ -d "$source_af/$item" ]; then
      while IFS= read -r src_file; do
        rel="${src_file#$source_af/$item/}"
        dest_file="$path/$rel"
        if [ ! -e "$dest_file" ]; then
          mkdir -p "$(dirname "$dest_file")"
          cp "$src_file" "$dest_file"
          seeded_count=$((seeded_count + 1))
        fi
      done < <(find "$source_af/$item" -type f)
    fi
    if [ "$seeded_count" -gt 0 ]; then
      echo "  PRESERVED: $item/; SEEDED $seeded_count missing starter file(s)"
    else
      echo "  PRESERVED: $item/"
    fi
  elif is_history_owned "$item"; then
    mkdir -p "$path"
    touch "$path/.gitkeep"
    echo "  CREATED: $item/ (clean history directory)"
  elif [ -d "$source_af/$item" ]; then
    cp -R "$source_af/$item" "$path"
    echo "  SEEDED: $item/"
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
project_name="$(basename "$target")"
tmp_template="$(mktemp)"
tmp_block="$(mktemp)"
sed "s/{project-name}/$project_name/g" "$agents_template" > "$tmp_template"
awk '
  /<!-- agent-flow:start -->/ { in_block = 1 }
  in_block { print }
  /<!-- agent-flow:end -->/ && in_block { exit }
' "$tmp_template" > "$tmp_block"

if [ -f "$agents_md" ]; then
  if grep -q "<!-- agent-flow:start -->" "$agents_md" 2>/dev/null && grep -q "<!-- agent-flow:end -->" "$agents_md" 2>/dev/null; then
    tmp_agents="$(mktemp)"
    awk -v block_file="$tmp_block" '
      BEGIN {
        while ((getline line < block_file) > 0) {
          block = block line "\n"
        }
      }
      /<!-- agent-flow:start -->/ {
        printf "%s", block
        skipping = 1
        next
      }
      /<!-- agent-flow:end -->/ {
        if (skipping) {
          skipping = 0
          next
        }
      }
      !skipping { print }
    ' "$agents_md" > "$tmp_agents"
    mv "$tmp_agents" "$agents_md"
    echo "  Replaced existing agent-flow block in AGENTS.md"
  else
    echo "" >> "$agents_md"
    cat "$tmp_template" >> "$agents_md"
    echo "  Appended agent-flow block to AGENTS.md"
  fi
else
  cp "$tmp_template" "$agents_md"
  echo "  Created AGENTS.md from template"
fi
rm -f "$tmp_template" "$tmp_block"

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
