#!/usr/bin/env bash
set -euo pipefail

change_dir=""
project_root="."

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: task-boundary-check.sh --change-dir <change-dir> [--project-root <path>]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ]; then
  echo "Missing required argument: --change-dir" >&2
  exit 2
fi

project_root="$(cd "$project_root" 2>/dev/null && pwd || echo "$project_root")"
if [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi
change_dir_abs="$(cd "$change_dir" && pwd)"
case "$change_dir_abs" in
  "$project_root"/*) change_rel="${change_dir_abs#$project_root/}" ;;
  *) change_rel="$change_dir" ;;
esac

tasks_path="$change_dir_abs/TASKS.md"
allowed=()
if [ -f "$tasks_path" ]; then
  while IFS= read -r line; do
    entry="$(printf '%s' "$line" | sed 's/^[[:space:]]*-[[:space:]]*//; s/^[`"'"'"']//; s/[`"'"'"']$//; s#\\#/#g')"
    [ -n "$entry" ] && allowed+=("$entry")
  done < <(
    awk '
      /^[[:space:]]*write_files[[:space:]]*:/ { in_section = 1; next }
      in_section && /^[[:space:]]*##[[:space:]]+/ { in_section = 0 }
      in_section && /^[[:space:]]*[A-Za-z0-9_-]+[[:space:]]*:[[:space:]]*$/ { in_section = 0 }
      in_section && /^[[:space:]]*-/ { print }
    ' "$tasks_path"
  )
fi

cd "$project_root"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "SKIP: task-boundary-check requires a git worktree."
  exit 0
fi

mapfile -t changed < <(
  {
    git diff --name-only
    git diff --cached --name-only
    git ls-files --others --exclude-standard
  } | sed 's#\\#/#g' | awk 'NF' | sort -u
)

violations=()
for file in "${changed[@]}"; do
  case "$file" in
    "$change_rel"|"$change_rel"/*) continue ;;
  esac

  matched=false
  for entry in "${allowed[@]}"; do
    entry="${entry%/}"
    if [ "$file" = "$entry" ] || [[ "$file" == "$entry/"* ]]; then
      matched=true
      break
    fi
  done

  if [ "$matched" = false ]; then
    violations+=("$file")
  fi
done

if [ "${#violations[@]}" -gt 0 ]; then
  echo "Task boundary check failed. Files changed outside TASKS.md write_files:"
  printf ' - %s\n' "${violations[@]}"
  if [ "${#allowed[@]}" -eq 0 ]; then
    echo "No write_files entries were found in TASKS.md."
  fi
  exit 2
fi

echo "Task boundary check passed: changed files are within write_files or the change folder."
