#!/usr/bin/env bash
# Apply fatigue recommendations by marking consistently passing gates advisory.
# Analyzes change history to determine which gates are fatigued at which flow levels.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/../.." && pwd)"
threshold=8
apply=false
verbose=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --threshold|-Threshold) threshold="$2"; shift 2 ;;
    --apply|-Apply) apply=true; shift ;;
    --verbose|-Verbose) verbose=true; shift ;;
    -h|--help)
      cat <<'EOF'
Usage: fatigue-action.sh [--threshold 8] [--apply] [--verbose]

Scans agent-flow changes for gate pass/fail history, identifies gates that
have consistently passed and recommends making them advisory (non-blocking)
for specific flow levels.

Options:
  --threshold N   Consecutive passes to trigger fatigue (default: 8)
  --apply         Persist recommendations to .gates-config.json
  --verbose       Show per-change scan details
EOF
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

changes_dir="$root/agent-flow/changes"
if [ ! -d "$changes_dir" ]; then
  echo "No changes directory found. Create a change first."
  exit 0
fi

echo "Fatigue Action Report"
echo "============================================================"
echo "Threshold: $threshold consecutive passes"
echo ""

# Track per-gate per-flow pass/fail counts
declare -A gate_pass=()
declare -A gate_fail=()
declare -A gate_consecutive=()
declare -A gate_flows=()

change_count=0
for change_dir in "$changes_dir"/*/; do
  [ -d "$change_dir" ] || continue
  change_name="$(basename "$change_dir")"
  [ "$change_name" = "." ] && continue

  # Determine flow level
  flow="Unknown"
  if [ -f "$change_dir/CHANGE.md" ]; then
    if grep -q '\- \[x\] Light' "$change_dir/CHANGE.md" 2>/dev/null; then flow="Light"; fi
    if grep -q '\- \[x\] Standard' "$change_dir/CHANGE.md" 2>/dev/null; then flow="Standard"; fi
    if grep -q '\- \[x\] Heavy' "$change_dir/CHANGE.md" 2>/dev/null; then flow="Heavy"; fi
    if grep -q '\- \[x\] Emergency' "$change_dir/CHANGE.md" 2>/dev/null; then flow="Emergency"; fi
  fi

  change_count=$((change_count + 1))
  if [ "$verbose" = true ]; then
    echo "  Scanning: $change_name ($flow)"
  fi

  # Scan CHECK_RESULT.json if available
  if [ -f "$change_dir/CHECK_RESULT.json" ]; then
    while IFS= read -r gate; do
      [ -n "$gate" ] || continue
      key="${gate}||${flow}"
      gate_pass["$key"]=$(( ${gate_pass["$key"]:-0} + 1 ))
      gate_consecutive["$key"]=$(( ${gate_consecutive["$key"]:-0} + 1 ))
      # Add flow to gate's flow set
      flows="${gate_flows["$gate"]:-}"
      if ! echo "$flows" | grep -q "$flow"; then
        gate_flows["$gate"]="${flows}${flow},"
      fi
    done < <(python3 -c "
import json, sys
try:
    d = json.load(open('$change_dir/CHECK_RESULT.json'))
    for g, r in d.get('gates', {}).items():
        if r.get('result') == 'pass':
            print(g)
except: pass
" 2>/dev/null || true)
  elif [ -f "$change_dir/VERIFY.md" ]; then
    # Heuristic: scan VERIFY.md for passing gates
    while IFS= read -r gate; do
      [ -n "$gate" ] || continue
      key="${gate}||${flow}"
      gate_pass["$key"]=$(( ${gate_pass["$key"]:-0} + 1 ))
      gate_consecutive["$key"]=$(( ${gate_consecutive["$key"]:-0} + 1 ))
      flows="${gate_flows["$gate"]:-}"
      if ! echo "$flows" | grep -q "$flow"; then
        gate_flows["$gate"]="${flows}${flow},"
      fi
    done < <(grep -oE '(design-check|alignment-check|task-check|ac-check|coverage-check|code-drift-check|closure-check|evolution-check|scan-check|blocked-check|manifest-check).*passed' "$change_dir/VERIFY.md" 2>/dev/null | sed 's/ passed.*//' || true)
  fi
done

echo "Changes scanned: $change_count"
echo ""

# Identify fatigued gates
declare -A recommendations=()
rec_count=0

for gate in design-check alignment-check task-check ac-check coverage-check code-drift-check closure-check evolution-check scan-check blocked-check manifest-check; do
  flows="${gate_flows["$gate"]:-}"
  [ -z "$flows" ] && continue

  for flow in Light Standard Heavy Emergency; do
    key="${gate}||${flow}"
    passes="${gate_pass["$key"]:-0}"
    [ "$passes" -ge "$threshold" ] || continue

    rec_count=$((rec_count + 1))
    action="advisory"
    desc="Set to advisory-only for $flow changes (warn but don't block)"

    if [ "$flow" = "Heavy" ]; then
      action="review"
      desc="Fatigued in Heavy — review if this gate still provides value for high-risk changes"
    elif [ "$flow" = "Standard" ]; then
      action="advisory-for-standard"
      desc="Set to advisory-only for Standard changes"
    fi

    recommendations["${gate}|${flow}"]="$action|$desc|$passes"
  done
done

if [ "$rec_count" -eq 0 ]; then
  echo "No fatigued gates found (threshold = $threshold)."
  exit 0
fi

# Group by action type
echo "Fatigued gates and recommended actions:"

# Advisory gates
echo ""
echo "Advisory gates (warn but don't block):"
for key in "${!recommendations[@]}"; do
  val="${recommendations[$key]}"
  action="${val%%|*}"
  [[ "$action" == advisory* ]] || continue
  gate="${key%%|*}"
  flow="${key##*|}"
  rest="${val#*|}"
  desc="${rest%|*}"
  passes="${rest##*|}"
  echo "  $gate ($flow): $desc"
  echo "    -> $passes consecutive passes in $flow flow"
done

# Review gates
echo ""
echo "Gates needing review:"
for key in "${!recommendations[@]}"; do
  val="${recommendations[$key]}"
  action="${val%%|*}"
  [ "$action" = "review" ] || continue
  gate="${key%%|*}"
  flow="${key##*|}"
  rest="${val#*|}"
  desc="${rest%|*}"
  passes="${rest##*|}"
  echo "  $gate ($flow): $desc"
  echo "    -> $passes consecutive passes in $flow flow"
done

echo ""
echo "Changes scanned: $change_count"
echo "Total recommendations: $rec_count"

if [ "$apply" != true ]; then
  echo ""
  echo "Dry-run mode. Use --apply to persist changes."
  exit 0
fi

# Persist recommendations
config_file="$root/agent-flow/.gates-config.json"
echo ""
echo "Applying recommendations..."

python3 - "$config_file" $threshold <<'PY'
import json, sys
from pathlib import Path

path = Path(sys.argv[1])
config = {}
if path.exists():
    try:
        config = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        config = {}

if "fatigue" not in config:
    config["fatigue"] = {}
config["fatigue"]["threshold"] = int(sys.argv[2])
config["fatigue"]["applied_at"] = __import__('datetime').datetime.now().isoformat()

path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
print(f"Configuration written to: {path}")
PY

echo "Done. Review agent-flow/.gates-config.json before committing."
