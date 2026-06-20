#!/usr/bin/env bash
# Run the shortest useful agent-flow onboarding path.

set -euo pipefail

target="."
demo_name="hello-agent-flow"
skip_demo=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target) target="$2"; shift 2 ;;
    --demo-name) demo_name="$2"; shift 2 ;;
    --skip-demo) skip_demo=true; shift ;;
    -h|--help)
      echo "Usage: af-quickstart.sh [--target .] [--demo-name hello-agent-flow] [--skip-demo]"
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

root="$(cd "$target" && pwd)"

run_step() {
  local label="$1"
  shift
  echo
  echo "== $label =="
  "$@"
}

echo "agent-flow quickstart"
echo "Project: $root"

health_script="$root/agent-flow/scripts/scaffold-health.sh"
[ -f "$health_script" ] || { echo "Missing $health_script. Install agent-flow first." >&2; exit 2; }
run_step "1. scaffold health" bash "$health_script"

manifest_script="$root/agent-flow/scripts/manifest-check.sh"
[ -f "$manifest_script" ] || { echo "Missing $manifest_script. Run init-project after installation." >&2; exit 2; }
run_step "2. manifest check" bash "$manifest_script"

change_dir="$root/agent-flow/changes/$demo_name"
if [ "$skip_demo" != true ]; then
  new_change="$root/agent-flow/scripts/new-change.sh"
  [ -f "$new_change" ] || { echo "Missing $new_change." >&2; exit 2; }
  echo
  echo "== 3. demo change =="
  if [ ! -d "$change_dir" ]; then
    bash "$new_change" --name "$demo_name" --flow Light
  fi
  change_file="$change_dir/CHANGE.md"
  if [ -f "$change_file" ]; then
    cat > "$change_file" <<EOF
# Change: $demo_name

## One-line Requirement
First agent-flow demo change.

## Flow Level

- [x] Light
- [ ] Standard
- [ ] Heavy
- [ ] Emergency

## Classification Reason

Demo only; no production code changes.

## Goal

- Learn the minimum agent-flow loop.

## Non-goals

- No application code changes.

## Impact

- none
EOF
  fi
  echo "Demo change ready: agent-flow/changes/$demo_name"
fi

relative_change_dir="agent-flow/changes/$demo_name"
if [ "$skip_demo" = true ]; then
  next_command="bash agent-flow/scripts/new-change.sh --name <change-id> --flow Standard"
else
  next_command="bash agent-flow/scripts/next-step.sh --change-dir $relative_change_dir"
fi

echo
echo "Recommended next command:"
echo "  $next_command"
echo
echo "Useful follow-ups:"
echo "  bash agent-flow/scripts/check-change.sh --change-dir $relative_change_dir"
echo "  bash agent-flow/scripts/dashboard.sh"
echo "  cat agent-flow/READING.md"
