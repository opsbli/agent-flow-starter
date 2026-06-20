#!/usr/bin/env bash
# Apply fatigue recommendations by marking consistently passing gates advisory.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/../.." && pwd)"
threshold=8
apply=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --threshold) threshold="$2"; shift 2 ;;
    --apply) apply=true; shift ;;
    -h|--help)
      echo "Usage: fatigue-action.sh [--threshold 8] [--apply]"
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

changes_dir="$root/agent-flow/changes"
if [ ! -d "$changes_dir" ]; then
  echo "No changes directory found"
  exit 0
fi

echo "Fatigue Action Report"
echo "============================================================"
echo "Threshold: $threshold consecutive passes"

change_count=0
for change_dir in "$changes_dir"/*/; do
  [ -d "$change_dir" ] || continue
  [ -f "$change_dir/CHECK_RESULT.json" ] || continue
  change_count=$((change_count + 1))
done
echo "Changes scanned: $change_count"

fatigue_output="$(bash "$script_dir/gate-fatigue-check.sh" --threshold "$threshold" 2>/dev/null || true)"
fatigued_gates="$(
  printf '%s\n' "$fatigue_output" |
    awk -F'|' '/\|/ && $2 !~ /Gate|---/ { gsub(/^[ \t]+|[ \t]+$/, "", $2); if ($2 != "") print $2 }' |
    sort -u |
    xargs || true
)"

if [ -z "$fatigued_gates" ]; then
  echo
  echo "No fatigued gates found."
  exit 0
fi

echo
echo "Fatigued gates:"
for gate in $fatigued_gates; do
  echo "  $gate"
done

echo
echo "Recommended action: advisory for Light changes."

if [ "$apply" != true ]; then
  echo
  echo "Dry-run mode. Use --apply to persist changes."
  exit 0
fi

config_file="$root/agent-flow/.gates-config.json"
python3 - "$config_file" $fatigued_gates <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
gates = sys.argv[2:]
config = {}
if path.exists():
    try:
        config = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        config = {}

advisory = list(config.get("advisory", []))
for gate in gates:
    if gate not in advisory:
        advisory.append(gate)
config["advisory"] = advisory
path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
PY

echo
echo "Configuration written to: agent-flow/.gates-config.json"
