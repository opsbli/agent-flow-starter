#!/usr/bin/env bash
set -euo pipefail

change_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: task-check.sh --change-dir <change-dir>"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ] || [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi

tasks_path="$change_dir/TASKS.md"
if [ ! -f "$tasks_path" ]; then
  echo "Task check failed:"
  echo " - Missing TASKS.md"
  exit 2
fi

issues=()
allowed_status='^(pending|not_started|in_progress|completed|blocked|skipped)$'
allowed_parallel='^(yes|no|true|false|allowed|blocked)$'

mapfile -t task_rows < <(grep -E '^\|[[:space:]]*T-?[0-9]+[A-Za-z]*[[:space:]]*\|' "$tasks_path" || true)
if [ "${#task_rows[@]}" -gt 0 ]; then
  for row in "${task_rows[@]}"; do
    IFS='|' read -r _ task_id status ac read_files write_files verify parallel _extra <<< "$row"
    task_id="$(printf '%s' "$task_id" | xargs)"
    status="$(printf '%s' "$status" | xargs)"
    ac="$(printf '%s' "$ac" | xargs)"
    read_files="$(printf '%s' "$read_files" | xargs)"
    write_files="$(printf '%s' "$write_files" | xargs)"
    verify="$(printf '%s' "$verify" | xargs)"
    parallel="$(printf '%s' "$parallel" | xargs)"

    [ -n "$parallel" ] || issues+=("Task Matrix row must have 7 columns: $row")
    printf '%s' "$status" | grep -Eiq "$allowed_status" || issues+=("$task_id has invalid Status: $status")
    printf '%s' "$ac" | grep -Eq 'AC-[0-9]{2}' || issues+=("$task_id must map to at least one AC id.")
    [ -n "$read_files" ] && ! printf '%s' "$read_files" | grep -Eiq 'TODO|TBD|待填写|path/to|example|示例|\{.+\}' || issues+=("$task_id must declare read_files.")
    [ -n "$write_files" ] && ! printf '%s' "$write_files" | grep -Eiq 'TODO|TBD|待填写|path/to|example|示例|\{.+\}' || issues+=("$task_id must declare write_files.")
    [ -n "$verify" ] && ! printf '%s' "$verify" | grep -Eiq 'TODO|TBD|待填写|path/to|example|示例|\{.+\}' || issues+=("$task_id must declare Verify.")
    printf '%s' "$parallel" | grep -Eiq "$allowed_parallel" || issues+=("$task_id has invalid Parallel value: $parallel")
  done
else
  if ! grep -Eq '^###[[:space:]]+T[-0-9A-Za-z]+' "$tasks_path"; then
    issues+=("TASKS.md must contain a Task Matrix row or task detail sections.")
  fi
  # Fallback for older task detail style.
  for required in "Status" "Goal" "AC" "read_files" "write_files" "Verify" "Parallel"; do
    if ! grep -Eq "^$required[[:space:]]*[:：][[:space:]]*[^[:space:]]" "$tasks_path"; then
      issues+=("TASKS.md missing non-empty '$required'.")
    fi
  done
  if ! grep -Eq 'AC-[0-9]{2}' "$tasks_path"; then
    issues+=("TASKS.md must map tasks to AC ids.")
  fi
fi

if ! grep -Eq '^[[:space:]]*write_files[[:space:]]*:' "$tasks_path"; then
  issues+=("TASKS.md must include a machine-readable write_files: list for task-boundary-check.")
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Task check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Task check passed."
