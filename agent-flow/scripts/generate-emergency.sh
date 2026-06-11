#!/usr/bin/env bash
# Generate emergency CANCEL.md and ROLLBACK.md with auto-filled timestamps
# Usage: bash agent-flow/scripts/generate-emergency.sh --change-dir <path>
set -euo pipefail
change_dir=""
while [ "$#" -gt 0 ]; do
  case "$1" in --change-dir|-ChangeDir) change_dir="$2"; shift 2 ;; *) echo "Unknown: $1"; exit 2 ;; esac
done
[ -z "$change_dir" ] && { echo "Error: --change-dir required"; exit 1; }
now=$(date '+%Y-%m-%d %H:%M')
today=$(date '+%Y-%m-%d')
change_id=$(basename "$change_dir")
change_desc="Emergency"
change_file="$change_dir/CHANGE.md"
[ -f "$change_file" ] && change_desc=$(grep -i "description:" "$change_file" 2>/dev/null | head -1 | sed 's/.*description://i' | sed 's/^[[:space:]]*//' || echo "Emergency")
cancel_out="$change_dir/CANCEL.md"
rollback_out="$change_dir/ROLLBACK.md"
if [ ! -f "$cancel_out" ]; then
  cat > "$cancel_out" << CANCELEOF
# Cancel / Abandon

## Change
- Change ID: $change_id
- Flow: Emergency
- Started: $now
- Cancelled: (fill)

## Reason for Cancellation
(fill)

## What Was Done
| Stage | Status | Notes |
|-------|--------|-------|
| Intake | (fill) | |
| Code Scan | (fill) | |
| Design | (fill) | |
| Implementation | (fill) | |
| Verification | (fill) | |

## Approval
- Cancelled by: (fill)
- Date: $today
CANCELEOF
  echo "CANCEL.md generated: $cancel_out"
fi
if [ ! -f "$rollback_out" ]; then
  cat > "$rollback_out" << ROLLBACKEOPF
# Rollback Plan

## Change
- Change ID: $change_id
- Description: $change_desc
- Rollback requested by: (fill)
- Date: $today

## Scope
- [ ] Full rollback
- [ ] Partial rollback

## Files to Revert
| File | Strategy | Risk |
|------|----------|------|
| (fill) | (fill) | (fill) |

## Verification After Rollback
- [ ] Compile passed
- [ ] Tests passed
- [ ] Schema reverted
- [ ] Manual smoke test passed
ROLLBACKEOPF
  echo "ROLLBACK.md generated: $rollback_out"
fi
echo "Emergency templates ready for: $change_id"
