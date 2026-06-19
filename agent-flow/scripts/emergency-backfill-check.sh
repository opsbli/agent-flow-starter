#!/usr/bin/env bash
# Check Emergency change backfill status — ensure 24h deadline is met.
# Usage: bash agent-flow/scripts/emergency-backfill-check.sh --change-dir <path> [--strict]

set -euo pipefail

CHANGE_DIR=""
STRICT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --change-dir) CHANGE_DIR="$2"; shift 2 ;;
    --strict) STRICT=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

[ -n "$CHANGE_DIR" ] || { echo "Usage: $0 --change-dir <path>"; exit 1; }
[ -d "$CHANGE_DIR" ] || { echo "Directory not found: $CHANGE_DIR"; exit 1; }

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

[ "$STATUS" = "waived" ] && { echo "Backfill waived."; exit 0; }

# Check deadline
if [ -n "$DEADLINE" ]; then
  echo "Deadline: $DEADLINE — Status: $STATUS"
else
  echo "No deadline set. Default +24h assumed."
fi

# Check required backfill artifacts
MISSING=0
for art in "REQUIREMENT.md" "CODE_SCAN.md" "DESIGN.md" "REVIEW.md" "AUDIT.md" "EVOLUTION.md"; do
  if [ ! -f "$CHANGE_DIR/$art" ]; then
    echo "  ❌ Missing: $art"
    MISSING=$((MISSING + 1))
  fi
done

if [ "$MISSING" -eq 0 ]; then
  echo "✅ All backfill artifacts present."
else
  echo "⚠️ $MISSING artifact(s) missing."
  [ "$STRICT" = true ] && exit 2
fi

echo "Backfill status: $STATUS"
exit 0
