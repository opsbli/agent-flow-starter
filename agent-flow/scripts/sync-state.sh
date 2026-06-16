#!/usr/bin/env bash
set -euo pipefail

change_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: sync-state.sh --change-dir <change-dir>"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ]; then
  echo "Missing required argument: --change-dir" >&2
  exit 2
fi
if [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
output="$(bash "$script_dir/next-step.sh" --change-dir "$change_dir")"
change_id="$(basename "$change_dir")"
flow="$(printf '%s\n' "$output" | sed -n 's/^[[:space:]]*"flow": "\([^"]*\)",\{0,1\}$/\1/p' | head -n 1)"
stage="$(printf '%s\n' "$output" | sed -n 's/^[[:space:]]*"stage": "\([^"]*\)",\{0,1\}$/\1/p' | head -n 1)"
next="$(printf '%s\n' "$output" | sed -n 's/^[[:space:]]*"next": "\([^"]*\)",\{0,1\}$/\1/p' | head -n 1)"
blocked_text="$(printf '%s\n' "$output" | awk '/"blocked": \[/,/\]/')"
date_value="$(date +%F)"

if printf '%s\n' "$blocked_text" | grep -q '"[^"]\+"'; then
  blocked="true"
  blockers="$(printf '%s\n' "$blocked_text" | sed -n 's/^[[:space:]]*"\([^"]*\)".*$/  - \1/p')"
else
  blocked="false"
  blockers="  - none"
fi

tail=""
if [ -f "$change_dir/STATE.md" ]; then
  tail="$(awk 'found { print } /^## Stage History/ { found = 1; print }' "$change_dir/STATE.md" | grep -vF 'YYYY-MM-DD' || true)"
fi

if [ -z "${tail//[[:space:]]/}" ]; then
  tail="## Stage History

| Time | Stage | Actor | Notes |
|---|---|---|---|
| $date_value | $stage | sync-state | Synced from next-step. |

## Notes

- STATE.md is a lightweight navigation aid.
- Source-of-truth remains the actual artifacts.
- If STATE.md conflicts with the artifacts, update it after checking next-step."
elif ! printf '%s\n' "$tail" | grep -Fq "| $date_value | $stage | sync-state | Synced from next-step. |"; then
  tail="$(printf '%s\n' "$tail" | awk -v row="| '"$date_value"' | '"$stage"' | sync-state | Synced from next-step. |" '
    { print }
    /^\|---\|---\|---\|---\|$/ && ! inserted { print row; inserted = 1 }
  ')"
fi

cat > "$change_dir/STATE.md" <<EOF
# State

change_id: $change_id
flow: $flow
current_stage: $stage
blocked: $blocked
blockers:
$blockers
next_action: $next
owner: unassigned
last_updated: $date_value

$tail
EOF

echo "STATE.md synced to stage '$stage'."
