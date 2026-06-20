#!/usr/bin/env bats
# Unit tests for task-check core functions.
# Run: bats agent-flow/test/unit/test-task-check.bats

setup() {
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../scripts" && pwd)"
    source "$DIR/_common.sh"
    TEST_DIR=$(mktemp -d)
}

teardown() {
    rm -rf "$TEST_DIR"
}

# Helper: extract AC-XX ids from text
get_ac_ids() {
    echo "$1" | grep -oE 'AC-[0-9]{2}' | sort -u
}

# Helper: check if verify text has task or AC evidence
has_verify_evidence() {
    local verify_text="$1"
    local task_id="$2"
    shift 2
    local ac_ids=("$@")
    
    if [ -z "$verify_text" ]; then
        return 1
    fi
    
    if echo "$verify_text" | grep -qF "$task_id"; then
        return 0
    fi
    
    for ac in "${ac_ids[@]}"; do
        if echo "$verify_text" | grep -qF "$ac"; then
            return 0
        fi
    done
    return 1
}

@test "get_ac_ids extracts single AC" {
    result=$(get_ac_ids "AC-01: do something")
    [ "$result" = "AC-01" ]
}

@test "get_ac_ids extracts multiple ACs" {
    result=$(get_ac_ids "AC-01, AC-02, AC-03")
    [ "$(echo "$result" | wc -l)" -eq 3 ]
}

@test "get_ac_ids returns unique values" {
    result=$(get_ac_ids "AC-01, AC-01, AC-02")
    [ "$(echo "$result" | wc -l)" -eq 2 ]
}

@test "get_ac_ids returns empty when no ACs" {
    result=$(get_ac_ids "No AC references here")
    [ -z "$result" ]
}

@test "get_ac_ids does not match single-digit AC-1" {
    result=$(get_ac_ids "AC-1 is wrong format")
    [ -z "$result" ]
}

@test "has_verify_evidence true when task id found" {
    run has_verify_evidence "T-01 completed" "T-01"
    [ "$status" -eq 0 ]
}

@test "has_verify_evidence true when AC id found" {
    run has_verify_evidence "AC-01 verified" "T-02" "AC-01"
    [ "$status" -eq 0 ]
}

@test "has_verify_evidence false when nothing found" {
    run has_verify_evidence "Some other content" "T-01" "AC-01"
    [ "$status" -eq 1 ]
}

@test "has_verify_evidence false for empty text" {
    run has_verify_evidence "" "T-01" "AC-01"
    [ "$status" -eq 1 ]
}

@test "has_verify_evidence true when any AC matches" {
    run has_verify_evidence "AC-03 done" "T-01" "AC-01" "AC-02" "AC-03"
    [ "$status" -eq 0 ]
}
