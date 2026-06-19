#!/usr/bin/env bash
# bats tests for agent-flow _common.sh shared functions
# Run: bats agent-flow/test/unit/test-common.bats

setup() {
    # Source the common functions
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../scripts" && pwd)"
    source "$DIR/_common.sh"

    # Create temp dir for file-based tests
    TEST_DIR=$(mktemp -d)
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "flow_level returns Emergency when CHANGE.md has Emergency checked" {
    local dir="$TEST_DIR/emergency"
    mkdir -p "$dir"
    cat > "$dir/CHANGE.md" <<EOF
## Flow Level

- [x] Emergency
- [ ] Heavy
- [ ] Standard
- [ ] Light
EOF
    result=$(flow_level "$dir")
    [ "$result" = "Emergency" ]
}

@test "flow_level returns Heavy when CHANGE.md has Heavy checked" {
    local dir="$TEST_DIR/heavy"
    mkdir -p "$dir"
    cat > "$dir/CHANGE.md" <<EOF
## Flow Level

- [ ] Emergency
- [x] Heavy
- [ ] Standard
- [ ] Light
EOF
    result=$(flow_level "$dir")
    [ "$result" = "Heavy" ]
}

@test "flow_level returns Standard when CHANGE.md has Standard checked" {
    local dir="$TEST_DIR/standard"
    mkdir -p "$dir"
    cat > "$dir/CHANGE.md" <<EOF
## Flow Level

- [ ] Emergency
- [ ] Heavy
- [x] Standard
- [ ] Light
EOF
    result=$(flow_level "$dir")
    [ "$result" = "Standard" ]
}

@test "flow_level returns Light when CHANGE.md has Light checked" {
    local dir="$TEST_DIR/light"
    mkdir -p "$dir"
    cat > "$dir/CHANGE.md" <<EOF
## Flow Level

- [ ] Emergency
- [ ] Heavy
- [ ] Standard
- [x] Light
EOF
    result=$(flow_level "$dir")
    [ "$result" = "Light" ]
}

@test "flow_level returns Unknown when CHANGE.md does not exist" {
    result=$(flow_level "$TEST_DIR/nonexistent")
    [ "$result" = "Unknown" ]
}

@test "flow_level returns Unknown when no level is checked" {
    local dir="$TEST_DIR/unchecked"
    mkdir -p "$dir"
    cat > "$dir/CHANGE.md" <<EOF
## Flow Level

- [ ] Emergency
- [ ] Heavy
EOF
    result=$(flow_level "$dir")
    [ "$result" = "Unknown" ]
}

@test "meaningful returns false for empty value" {
    run meaningful ""
    [ "$status" -eq 1 ]
}

@test "meaningful returns false for TODO" {
    run meaningful "TODO"
    [ "$status" -eq 1 ]
}

@test "meaningful returns false for TBD" {
    run meaningful "TBD"
    [ "$status" -eq 1 ]
}

@test "meaningful returns false for path/to pattern" {
    run meaningful "path/to/something"
    [ "$status" -eq 1 ]
}

@test "meaningful returns false for example placeholder" {
    run meaningful "example-project"
    [ "$status" -eq 1 ]
}

@test "meaningful returns true for valid value" {
    run meaningful "user-profile-module"
    [ "$status" -eq 0 ]
}

@test "meaningful returns true for PostgreSQL" {
    run meaningful "PostgreSQL"
    [ "$status" -eq 0 ]
}

@test "meaningful returns false for value with slash without allow_slash" {
    run meaningful "src/main" false
    [ "$status" -eq 1 ]
}

@test "meaningful returns true for value with slash with allow_slash" {
    run meaningful "src/main" true
    [ "$status" -eq 0 ]
}

@test "meaningful_file returns false when file does not exist" {
    run meaningful_file "$TEST_DIR/nonexistent.md"
    [ "$status" -eq 1 ]
}

@test "meaningful_file returns false when file is empty" {
    local path="$TEST_DIR/empty.md"
    touch "$path"
    run meaningful_file "$path"
    [ "$status" -eq 1 ]
}

@test "meaningful_file returns false when file contains TODO placeholder" {
    local path="$TEST_DIR/todo.md"
    echo "TODO" > "$path"
    run meaningful_file "$path" "TODO"
    [ "$status" -eq 1 ]
}

@test "meaningful_file returns true for valid file" {
    local path="$TEST_DIR/valid.md"
    echo "# Real Content" > "$path"
    echo "This is actual documentation." >> "$path"
    run meaningful_file "$path"
    [ "$status" -eq 0 ]
}
