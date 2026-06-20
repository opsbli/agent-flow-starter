#!/usr/bin/env bash
# Check Emergency change backfill status — ensure 24h deadline is met.
# Usage: bash agent-flow/scripts/emergency-backfill-check.sh --change-dir <path> [--strict]

set -euo pipefail

CHANGE_DIR=""
STRICT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --change-dir|-ChangeDir) CHANGE_DIR="$2"; shift 2 ;;
    --strict|-Strict) STRICT=true; shift ;;
    -h|--help)
      cat <<'EOF'
Usage: emergency-backfill-check.sh --change-dir <path> [--strict]

Checks Emergency change backfill status:
  - Verifies 24h deadline compliance
  - Checks all required backfill artifacts exist
  - Warns if pitfalls.md not updated after the incident

Exit 0 if backfill is complete or not an Emergency change.
Exit 2 if strict mode and backfill is incomplete/overdue.
EOF
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

[ -n "$CHANGE_DIR" ] || { echo "Usage: $0 --change-dir <path>" >&2; exit 1; }
[ -d "$CHANGE_DIR" ] || { echo "Directory not found: $CHANGE_DIR" >&2; exit 1; }

CHANGE_FILE="$CHANGE_DIR/CHANGE.md"
[ -f "$CHANGE_FILE" ] || { echo "CHANGE.md not found — not an Emergency change?"; exit 0; }

CHANGE_TEXT="$(cat "$CHANGE_FILE")"

# Verify this is Emergency
echo "$CHANGE_TEXT" | grep -Eqi '\[x\][[:space:]]+Emergency' || {
  echo "Not an Emergency change. Skipping."
  exit 0
}

# Extract metadata
LEVEL=$(echo "$CHANGE_TEXT" | grep -Eim1 'Level:\s*(P[01])' | sed 's/.*Level:[[:space:]]*//i' || echo "")
DEADLINE=$(echo "$CHANGE_TEXT" | grep -Eim1 'Backfill deadline:\s*(.+)' | sed 's/.*deadline:[[:space:]]*//i' || echo "")
STATUS=$(echo "$CHANGE_TEXT" | grep -Eim1 'Backfill status:\s*(\S+)' | sed 's/.*status:[[:space:]]*//i' || echo "pending")

[ "$STATUS" = "waived" ] && { echo "Backfill waived (explicitly noted in CHANGE.md)."; exit 0; }

# Check deadline with actual date parsing
if [ -n "$DEADLINE" ]; then
  # Try to parse deadline as date (GNU date)
  if command -v date >/dev/null 2>&1; then
    deadline_epoch=$(date -d "$DEADLINE" +%s 2>/dev/null || echo 0)
    now_epoch=$(date +%s)
    if [ "$deadline_epoch" -gt 0 ] && [ "$now_epoch" -gt "$deadline_epoch" ] && [ "$STATUS" != "done" ]; then
      echo "BACKFILL OVERDUE: Deadline was $DEADLINE (status: $STATUS)"
      [ "$STRICT" = true ] && exit 2
    else
      echo "Deadline: $DEADLINE — $([ "$STATUS" = "done" ] && echo 'done' || echo 'pending, still within window')"
    fi
  else
    echo "Deadline: $DEADLINE — Status: $STATUS"
  fi
else
  echo "No deadline set in CHANGE.md. Defaulting to +24h from now."
fi

# Check required backfill artifacts
MISSING=0
declare -A ARTIFACTS=(
  ["REQUIREMENT.md"]="REQUIREMENT.md (full)"
  ["CODE_SCAN.md"]="CODE_SCAN.md (full)"
  ["DESIGN.md"]="DESIGN.md (with Design Alignment)"
  ["REVIEW.md"]="REVIEW.md"
  ["AUDIT.md"]="AUDIT.md (Closure Audit)"
  ["EVOLUTION.md"]="EVOLUTION.md"
)

for art in "${!ARTIFACTS[@]}"; do
  desc="${ARTIFACTS[$art]}"
  if [ ! -f "$CHANGE_DIR/$art" ]; then
    echo "  Missing: $desc"
    MISSING=$((MISSING + 1))
  fi
done

if [ "$MISSING" -eq 0 ]; then
  echo "All backfill artifacts present."
else
  echo "$MISSING artifact(s) missing."
  [ "$STRICT" = true ] && exit 2
fi

# Check pitfalls.md freshness (should be updated after incident)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/../.." && pwd)"
pitfalls_path="$project_root/agent-flow/knowledge/pitfalls.md"
if [ -f "$pitfalls_path" ] && [ -f "$CHANGE_FILE" ]; then
  change_mtime=$(stat -c %Y "$CHANGE_FILE" 2>/dev/null || stat -f %m "$CHANGE_FILE" 2>/dev/null || echo 0)
  pitfalls_mtime=$(stat -c %Y "$pitfalls_path" 2>/dev/null || stat -f %m "$pitfalls_path" 2>/dev/null || echo 0)
  if [ "$pitfalls_mtime" -lt "$change_mtime" ] 2>/dev/null; then
    echo "pitfalls.md not updated since before the Emergency change. Review and update if applicable."
  fi
fi

echo ""
echo "Backfill status: $STATUS"
exit 0
