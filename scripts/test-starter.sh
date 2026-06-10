#!/usr/bin/env bash
set -euo pipefail

keep_temp=false
if [ "${1:-}" = "--keep-temp" ]; then
  keep_temp=true
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
starter_root="$(cd "$script_dir/.." && pwd)"
temp_root="$(mktemp -d)"
empty_target="$temp_root/empty-project"
update_target="$temp_root/update-project"

cleanup() {
  if [ "$keep_temp" = true ]; then
    echo "Temp kept: $temp_root"
  else
    rm -rf "$temp_root"
  fi
}
trap cleanup EXIT

assert_path() {
  if [ ! -e "$1" ]; then
    echo "Expected path not found: $1" >&2
    exit 1
  fi
}

echo "== scaffold health =="
bash "$starter_root/agent-flow/scripts/scaffold-health.sh"
if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -File "$starter_root/agent-flow/scripts/scaffold-health.ps1"
fi

echo "== syntax =="
find "$starter_root/agent-flow/scripts" "$starter_root/scripts" -name '*.sh' -print0 | xargs -0 -n1 bash -n

echo "== install empty target =="
mkdir -p "$empty_target"
bash "$starter_root/scripts/install-agent-flow.sh" --target "$empty_target"
assert_path "$empty_target/AGENTS.md"
assert_path "$empty_target/agent-flow/GO.md"
bash "$empty_target/agent-flow/scripts/init-project.sh" --target "$empty_target"
bash "$empty_target/agent-flow/scripts/run-verify.sh" --all

echo "== update existing AGENTS.md =="
mkdir -p "$update_target"
cat > "$update_target/AGENTS.md" <<'EOF'
# Existing Rules

keep me

<!-- agent-flow:start -->
old block
<!-- agent-flow:end -->
EOF
bash "$starter_root/scripts/install-agent-flow.sh" --target "$update_target"
grep -q "keep me" "$update_target/AGENTS.md"
if grep -q "old block" "$update_target/AGENTS.md"; then
  echo "Old agent-flow block was not replaced." >&2
  exit 1
fi
grep -q "agent-flow/GO.md" "$update_target/AGENTS.md"

echo "== residue scan =="
if rg -n "ops-pilot|RuoYi|ruoyi|ops-ai|ops-flow|ops-asset|ops-monitor|ops-workflow|inbound|入库|BusinessStatusEnum|wf_business_status" "$starter_root" --glob "!scripts/test-starter.*"; then
  echo "Project-specific residue found." >&2
  exit 1
fi

echo "== docs/examples =="
assert_path "$starter_root/docs/ADOPTION.md"
assert_path "$starter_root/docs/PROMPTS.md"
assert_path "$starter_root/examples/sample-change/VERIFY.md"

echo "agent-flow starter self-test passed."
