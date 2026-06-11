#!/usr/bin/env bash
set -euo pipefail

change_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: scan-check.sh --change-dir <change-dir>"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ] || [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi

scan_path="$change_dir/CODE_SCAN.md"
if [ ! -f "$scan_path" ]; then
  echo "Scan check failed:"
  echo " - Missing CODE_SCAN.md"
  exit 2
fi

flow="Unknown"
if [ -f "$change_dir/CHANGE.md" ]; then
  if grep -Eiq '\[x\][[:space:]]+Heavy' "$change_dir/CHANGE.md"; then flow="Heavy"
  elif grep -Eiq '\[x\][[:space:]]+Standard' "$change_dir/CHANGE.md"; then flow="Standard"
  elif grep -Eiq '\[x\][[:space:]]+Light' "$change_dir/CHANGE.md"; then flow="Light"
  fi
fi

key_value() {
  local key="$1"
  sed -nE "s/^[[:space:]]*$key[[:space:]]*:[[:space:]]*(.+)$/\1/ip" "$scan_path" | head -n 1
}

meaningful() {
  local value="$1"
  [ -n "$(printf '%s' "$value" | tr -d '[:space:]')" ] || return 1
  ! printf '%s' "$value" | grep -Eiq 'TODO|TBD|待填写|path/to|example|示例|\{.+\}'
}

issues=()
required=(scan_time read_files write_files open_questions)
if [ "$flow" = "Standard" ] || [ "$flow" = "Heavy" ]; then
  required+=(related_modules similar_implementations reusable_abstractions test_baseline)
fi

for key in "${required[@]}"; do
  content="$(key_value "$key")"
  if ! meaningful "$content"; then
    issues+=("CODE_SCAN.md key '$key' is missing or still empty.")
  fi
done

if ! grep -Eiq 'read_files[[:space:]]*:|^##[[:space:]]+read_files' "$scan_path"; then
  issues+=("CODE_SCAN.md must declare read_files.")
fi
if ! grep -Eiq 'write_files[[:space:]]*:|^##[[:space:]]+write_files' "$scan_path"; then
  issues+=("CODE_SCAN.md must declare write_files.")
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Scan check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Scan check passed for $flow change."
