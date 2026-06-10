#!/usr/bin/env bash
set -euo pipefail

target=""
force=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target|-Target)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      target="$2"
      shift 2
      ;;
    --force|-Force)
      force=true
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage: scripts/install-agent-flow.sh --target <project-root> [--force]

Copies agent-flow into a target project and creates or updates the agent-flow
block in AGENTS.md.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$target" ]; then
  echo "Missing required argument: --target" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
starter_root="$(cd "$script_dir/.." && pwd)"
source_flow="$starter_root/agent-flow"

if [ ! -d "$source_flow" ]; then
  echo "agent-flow source not found: $source_flow" >&2
  exit 1
fi

mkdir -p "$target"
target_root="$(cd "$target" && pwd)"
target_flow="$target_root/agent-flow"
backup_root="$(mktemp -d)"

if [ -d "$target_flow" ]; then
  for dir in changes logs reports knowledge decisions; do
    if [ -d "$target_flow/$dir" ]; then
      mkdir -p "$backup_root"
      cp -R "$target_flow/$dir" "$backup_root/$dir"
    fi
  done

  if [ "$force" = true ]; then
    rm -rf "$target_flow"
  fi
fi

rm -rf "$target_flow"
cp -R "$source_flow" "$target_flow"

for dir in changes logs reports knowledge decisions; do
  if [ -d "$backup_root/$dir" ]; then
    rm -rf "$target_flow/$dir"
    cp -R "$backup_root/$dir" "$target_flow/$dir"
  fi
done

rm -rf "$backup_root"

project_name="$(basename "$target_root")"
agents_template="$source_flow/templates/AGENTS.md"
agents_path="$target_root/AGENTS.md"
tmp_block="$(mktemp)"
sed "s/{project-name}/$project_name/g" "$agents_template" > "$tmp_block"

if [ -f "$agents_path" ]; then
  if grep -q '<!-- agent-flow:start -->' "$agents_path" && grep -q '<!-- agent-flow:end -->' "$agents_path"; then
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
    ' "$agents_path" > "$tmp_agents"
    mv "$tmp_agents" "$agents_path"
  else
    {
      sed -e '${/^$/d;}' "$agents_path"
      printf '\n\n'
      cat "$tmp_block"
    } > "$agents_path.tmp"
    mv "$agents_path.tmp" "$agents_path"
  fi
else
  cp "$tmp_block" "$agents_path"
fi

rm -f "$tmp_block"

bash "$target_flow/scripts/scaffold-health.sh"

echo "agent-flow installed into $target_root"
echo "Next: run bash agent-flow/scripts/init-project.sh in the target project, then review TODO values."
