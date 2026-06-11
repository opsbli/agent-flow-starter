#!/usr/bin/env bash
set -euo pipefail

change_dir=""
project_root="."
closure=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    --closure|-Closure)
      closure=true; shift ;;
    -h|--help)
      echo "Usage: check-change.sh --change-dir <change-dir> [--project-root <path>] [--closure]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ] || [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failed=0

run_gate() {
  local name="$1"; shift
  echo "== $name =="
  if ! "$@"; then
    echo "Gate failed: $name" >&2
    failed=1
  fi
}

has_file() {
  [ -f "$change_dir/$1" ]
}

run_gate sync-state bash "$script_dir/sync-state.sh" --change-dir "$change_dir"
run_gate state-check bash "$script_dir/state-check.sh" --change-dir "$change_dir"

if has_file CODE_SCAN.md; then
  run_gate scan-check bash "$script_dir/scan-check.sh" --change-dir "$change_dir"
fi
if has_file DESIGN.md; then
  run_gate alignment-check bash "$script_dir/alignment-check.sh" --change-dir "$change_dir"
fi
if has_file TASKS.md; then
  run_gate task-check bash "$script_dir/task-check.sh" --change-dir "$change_dir"
  run_gate task-boundary-check bash "$script_dir/task-boundary-check.sh" --change-dir "$change_dir" --project-root "$project_root"
fi
if has_file REQUIREMENT.md && has_file VERIFY.md; then
  run_gate ac-check bash "$script_dir/ac-check.sh" --change-dir "$change_dir"
fi
if has_file DESIGN.md; then
  run_gate code-drift-check bash "$script_dir/code-drift-check.sh" --change-dir "$change_dir" --project-root "$project_root"
fi
if has_file TASKS.md; then
  run_gate blocked-check bash "$script_dir/blocked-check.sh" --change-dir "$change_dir" --project-root "$project_root"
fi
run_gate manifest-check bash "$script_dir/manifest-check.sh" --project-root "$project_root"

if has_file EVOLUTION.md; then
  run_gate evolution-check bash "$script_dir/evolution-check.sh" --change-dir "$change_dir"
fi
if [ "$closure" = true ] || { has_file VERIFY.md && has_file REPORT.md; }; then
  run_gate closure-check bash "$script_dir/closure-check.sh" --change-dir "$change_dir" --project-root "$project_root"
fi

if [ "$failed" -ne 0 ]; then
  echo "check-change failed." >&2
  exit 2
fi

echo "check-change passed."
