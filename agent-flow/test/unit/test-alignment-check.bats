#!/usr/bin/env bats
# Unit tests for alignment-check core parser functions.
# Run: bats agent-flow/test/unit/test-alignment-check.bats

setup() {
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../scripts" && pwd)"
    source "$DIR/_common.sh"
    TEST_DIR=$(mktemp -d)
}

teardown() {
    rm -rf "$TEST_DIR"
}

# Helper: extract alignment verdict from a text file
get_verdict() {
    local path="$1"
    if [ ! -f "$path" ]; then
        echo ""
        return
    fi
    grep -i "Alignment Verdict:" "$path" | sed 's/.*Alignment Verdict:\s*//i' | tr '[:upper:]' '[:lower:]'
}

# Helper: extract the Design Alignment / Grill section
get_alignment_section() {
    local text="$1"
    echo "$text" | awk '/## Design Alignment \/ Grill/,/^## /' | head -n -1
}

@test "get_verdict extracts 'aligned' from valid DESIGN.md" {
    cat > "$TEST_DIR/design.md" <<EOF
# Design

## Alignment Verdict: aligned

Content
EOF
    result=$(get_verdict "$TEST_DIR/design.md")
    [ "$result" = "aligned" ]
}

@test "get_verdict extracts 'skipped' with reason" {
    cat > "$TEST_DIR/design.md" <<EOF
## Alignment Verdict: skipped
Skip Reason: User approved
EOF
    result=$(get_verdict "$TEST_DIR/design.md")
    [ "$result" = "skipped" ]
}

@test "get_verdict returns empty when verdict missing" {
    cat > "$TEST_DIR/design.md" <<EOF
# Design (no verdict)
EOF
    result=$(get_verdict "$TEST_DIR/design.md")
    [ -z "$result" ]
}

@test "get_verdict returns empty when file not found" {
    result=$(get_verdict "$TEST_DIR/nonexistent.md")
    [ -z "$result" ]
}

@test "get_verdict handles case variations" {
    cat > "$TEST_DIR/design.md" <<EOF
## Alignment Verdict: BLOCKED
EOF
    result=$(get_verdict "$TEST_DIR/design.md")
    [ "$result" = "blocked" ]
}

@test "get_alignment_section extracts the alignment section" {
    text=$(cat <<'EOF'
# Design

## Design Alignment / Grill

Question 1: test
Confirmation: user-confirmed

## Plan

Plan content
EOF
)
    section=$(get_alignment_section "$text")
    echo "$section" | grep -q "Question 1"
    echo "$section" | grep -q "user-confirmed"
    ! echo "$section" | grep -q "Plan"
}

@test "get_alignment_section returns empty when no section" {
    text="# Design\n## Plan\nNo alignment here"
    section=$(get_alignment_section "$text")
    [ -z "$section" ]
}

@test "counts user-confirmed in section" {
    text=$(cat <<'EOF'
## Design Alignment / Grill

Q1
Confirmation: user-confirmed

Q2
Confirmation: user-confirmed

Q3
Confirmation: code-confirmed
EOF
)
    count=$(echo "$text" | grep -c "user-confirmed")
    [ "$count" -eq 2 ]
}
