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

changes_root="$root/agent-flow/changes"
change_dir="$changes_root/$demo_name"
if [ "$skip_demo" != true ]; then
  new_change="$root/agent-flow/scripts/new-change.sh"
  [ -f "$new_change" ] || { echo "Missing $new_change." >&2; exit 2; }
  echo
  echo "== 3. demo change =="
  existing="$(find "$changes_root" -maxdepth 1 -type d -name "*$demo_name" | sort | tail -n 1 || true)"
  if [ -n "$existing" ]; then
    change_dir="$existing"
  else
    bash "$new_change" --name "$demo_name" --flow Light --changes-root "$changes_root" --template-root "$root/agent-flow/templates" --force
    created="$(find "$changes_root" -maxdepth 1 -type d -name "*$demo_name" | sort | tail -n 1 || true)"
    [ -n "$created" ] || { echo "new-change did not create a directory for $demo_name" >&2; exit 2; }
    change_dir="$created"
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
  relative_created="${change_dir#$root/}"
  echo "Demo change ready: $relative_created"
fi

if [ "$skip_demo" = true ]; then
  relative_change_dir="agent-flow/changes/$demo_name"
else
  relative_change_dir="${change_dir#$root/}"
fi
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
