#!/usr/bin/env bash
# ==========================================
# Bundle agent-flow-relevant ECC skills from npm install
# Run this after 'pi install npm:ecc-universal' to refresh pi-package/skills/
# ==========================================
# Usage:
#   bash scripts/bundle-ecc-skills.sh
# ==========================================

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
starter_root="$(cd "$script_dir/.." && pwd)"
ecc_skills="$HOME/.pi/agent/npm/node_modules/ecc-universal/skills"
target_dir="$starter_root/pi-package/skills"

if [ ! -d "$ecc_skills" ]; then
  echo "ECC npm package not found at $ecc_skills"
  echo "Run: pi install npm:ecc-universal"
  exit 1
fi

# agent-flow relevant skills (32 out of 197)
needed=(
  "search-first"
  "api-design"
  "backend-patterns"
  "frontend-patterns"
  "database-migrations"
  "postgres-patterns"
  "error-handling"
  "docker-patterns"
  "deployment-patterns"
  "coding-standards"
  "mcp-server-patterns"
  "security-review"
  "security-scan"
  "python-patterns"
  "golang-patterns"
  "rust-patterns"
  "react-patterns"
  "java-coding-standards"
  "kotlin-patterns"
  "swiftui-patterns"
  "dart-flutter-patterns"
  "dotnet-patterns"
  "cpp-coding-standards"
  "nestjs-patterns"
  "fastapi-patterns"
  "verification-loop"
  "eval-harness"
  "e2e-testing"
  "tdd-workflow"
  "benchmark-optimization-loop"
  "continuous-learning-v2"
  "council"
)

mkdir -p "$target_dir"

copied=0
missing=0
for name in "${needed[@]}"; do
  src="$ecc_skills/$name"
  skill_md="$src/SKILL.md"
  if [ -f "$skill_md" ]; then
    dst="$target_dir/$name"
    mkdir -p "$dst"
    cp "$skill_md" "$dst/SKILL.md"
    copied=$((copied + 1))
  else
    echo "  MISSING: $name" >&2
    missing=$((missing + 1))
  fi
done

total_size=$(find "$target_dir" -name 'SKILL.md' -exec stat -f%z {} \; 2>/dev/null | awk '{s+=$1} END {printf "%.0f", s/1024}')
if [ -z "$total_size" ]; then
  # Linux stat fallback
  total_size=$(find "$target_dir" -name 'SKILL.md' -exec stat -c%s {} \; 2>/dev/null | awk '{s+=$1} END {printf "%.0f", s/1024}')
fi

echo ""
echo "agent-flow skill bundle complete"
echo "  Target: $target_dir"
echo "  Copied: $copied skills"
echo "  Missing: $missing"
echo "  Size: ${total_size:-?} KB"
echo "  (was 197 ECC skills, now $copied - $((copied * 100 / 197))%)"
