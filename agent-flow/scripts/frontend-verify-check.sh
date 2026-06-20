#!/usr/bin/env bash
# Enforce frontend verification evidence in VERIFY.md.
# When manifest.yaml declares a frontend framework, this gate checks that:
# 1. VERIFY.md exists and contains frontend verification evidence
# 2. If verify_required is true, frontend evidence must appear in AC Evidence table
#
# Exit codes:
#   0 = frontend verification satisfied (or no frontend)
#   1 = frontend verification required but evidence missing
#   2 = manifest.yaml not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$ROOT_DIR/agent-flow/manifest.yaml"
CHANGE_DIR="${1:-}"

if [ ! -f "$MANIFEST" ]; then
    echo "❌ Manifest not found: $MANIFEST"
    exit 2
fi

# Check if frontend framework is declared (and not "none")
if grep -qE '^\s+framework:\s+(none)\s*$' "$MANIFEST"; then
    echo "✓ No frontend framework declared — skipping frontend verification"
    exit 0
fi

FRAMEWORK=$(grep -oP '^\s+framework:\s*\K\S+' "$MANIFEST" || echo "unknown")
echo "Frontend framework detected: $FRAMEWORK"

if [ -z "$CHANGE_DIR" ]; then
    echo "❌ Change directory argument is required when frontend.framework is not none"
    exit 1
fi

VERIFY_PATH="$ROOT_DIR/$CHANGE_DIR/VERIFY.md"

if [ ! -f "$VERIFY_PATH" ]; then
    echo "❌ VERIFY.md not found at $VERIFY_PATH"
    echo "  Frontend changes require VERIFY.md with verification evidence."
    exit 1
fi

VERIFY_CONTENT=$(cat "$VERIFY_PATH")

# Check if verify_required is true
VERIFY_REQUIRED=false
if grep -qE '^\s+verify_required:\s*true' "$MANIFEST"; then
    VERIFY_REQUIRED=true
fi

# Check 1: AC Evidence table must exist
if ! echo "$VERIFY_CONTENT" | grep -qE '\| AC-[0-9]+'; then
    echo "⚠️  No AC Evidence table found in VERIFY.md"
    if [ "$VERIFY_REQUIRED" = true ]; then
        echo "❌ verify_required=true — frontend AC Evidence is mandatory"
        exit 1
    fi
fi

# Check 2: Frontend-specific keywords
FOUND_COUNT=0
for kw in "DevTools" "Chrome DevTools" "Network" "Console" "Elements" "视觉" "UI" "联调" "e2e" "E2E" "browser" "前端验证" "typecheck" "tsc" "lint" "component test"; do
    if echo "$VERIFY_CONTENT" | grep -qiF "$kw"; then
        FOUND_COUNT=$((FOUND_COUNT + 1))
    fi
done

if [ "$FOUND_COUNT" -eq 0 ]; then
    echo "⚠️  No frontend verification keywords found in VERIFY.md"
    echo "  Expected at least one of: DevTools, Console, UI, 联调, e2e, typecheck, lint"
    if [ "$VERIFY_REQUIRED" = true ]; then
        echo "❌ verify_required=true — frontend evidence is mandatory"
        exit 1
    fi
else
    echo "✓ Frontend verification evidence found ($FOUND_COUNT keywords matched)"
fi

# Check 3: Chrome DevTools specific checks for verify_required
if [ "$VERIFY_REQUIRED" = true ]; then
    for check in "Network 无 4xx" "Console 无报错" "Elements" "Application"; do
        if ! echo "$VERIFY_CONTENT" | grep -qF "$check"; then
            echo "⚠️  Missing DevTools check evidence: $check"
        fi
    done
    echo "  Refer to agent-flow/core/frontend-fit.md for the complete checklist."
fi

echo "✓ Frontend verification check passed"
exit 0
