#!/usr/bin/env bash
# Collect and persist CI performance baseline data.
# Called from CI after scaffold-health step; saves to agent-flow/reports/performance-baseline.json
# Usage: bash agent-flow/scripts/collect-baseline.sh --gate <name> --duration-ms <ms>
set -euo pipefail

gate=""
duration_ms=""
baseline_file="agent-flow/reports/performance-baseline.json"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --gate|-Gate) gate="$2"; shift 2 ;;
    --duration-ms|-DurationMs) duration_ms="$2"; shift 2 ;;
    --baseline-file|-BaselineFile) baseline_file="$2"; shift 2 ;;
    -h|--help) echo "Usage: $0 --gate <name> --duration-ms <ms>"; exit 0 ;;
    *) echo "Unknown: $1" >&2; exit 2 ;;
  esac
done

[ -n "$gate" ] || { echo "ERROR: --gate required" >&2; exit 2; }
[ -n "$duration_ms" ] || { echo "ERROR: --duration-ms required" >&2; exit 2; }

data="{}"
[ -f "$baseline_file" ] && data=$(cat "$baseline_file")

# Append or update this gate's timing
updated=$(echo "$data" | python3 -c "
import json, sys
data = json.load(sys.stdin)
date = '$gate'
data['$gate'] = { 'duration_ms': $duration_ms, 'timestamp': '$(date -Iseconds)', 'threshold_ms': 5000 }
print(json.dumps(data, indent=2))
" 2>/dev/null || echo "$data")

echo "$updated" > "$baseline_file"
echo "Recorded: $gate = ${duration_ms}ms"