#!/usr/bin/env bash
# Interactive initialization wizard for agent-flow.
# Guides through project setup with smart defaults and contextual questions.
# Usage: bash agent-flow/scripts/init-wizard.sh [--target /path/to/project] [--non-interactive]

set -euo pipefail

TARGET="."
NON_INTERACTIVE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --non-interactive) NON_INTERACTIVE=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

ROOT="$(cd "$TARGET" && pwd)"
PROJECT_NAME="$(basename "$ROOT")"

# ── Colors ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

# ──────────────────────────────────────────────
# Step 1: Auto-detection
# ──────────────────────────────────────────────

has_file() { [ -f "$ROOT/$1" ]; }
existing_dirs() {
  for d in "$@"; do
    [ -d "$ROOT/$d" ] && echo "$d"
  done
}

BUILD="unknown"
BACKEND_LANG="unknown"
BACKEND_FRAMEWORK="unknown"
BACKEND_COMPILE="TODO_BACKEND_COMPILE_COMMAND"
BACKEND_TEST="TODO_BACKEND_TEST_COMMAND"
MODULE_COMPILE="TODO_MODULE_COMPILE_COMMAND"
MODULE_TEST="TODO_MODULE_TEST_COMMAND"

if has_file "pom.xml"; then
  BUILD="Maven"; BACKEND_LANG="Java"; BACKEND_FRAMEWORK="Java"
  BACKEND_COMPILE="mvn compile -DskipTests -q"; BACKEND_TEST="mvn test -q"
  MODULE_COMPILE="mvn compile -pl {module} -am -DskipTests -q"; MODULE_TEST="mvn test -pl {module} -am -q"
elif has_file "build.gradle"; then
  BUILD="Gradle"; BACKEND_LANG="Java/Kotlin"; BACKEND_FRAMEWORK="Gradle"
  BACKEND_COMPILE="./gradlew build -x test"; BACKEND_TEST="./gradlew test"
  MODULE_COMPILE="./gradlew :{module}:build -x test"; MODULE_TEST="./gradlew :{module}:test"
elif has_file "pyproject.toml"; then
  BUILD="Python"; BACKEND_LANG="Python"; BACKEND_FRAMEWORK="Python"
  BACKEND_COMPILE="python -m compileall ."; BACKEND_TEST="pytest"
elif has_file "go.mod"; then
  BUILD="Go"; BACKEND_LANG="Go"; BACKEND_FRAMEWORK="Go"
  BACKEND_COMPILE="go vet ./..."; BACKEND_TEST="go test ./..."
elif has_file "Cargo.toml"; then
  BUILD="Cargo"; BACKEND_LANG="Rust"; BACKEND_FRAMEWORK="Rust"
  BACKEND_COMPILE="cargo check"; BACKEND_TEST="cargo test"
fi

FRONTEND_LANG="none"; FRONTEND_FRAMEWORK="none"; FRONTEND_REPO="none"
FRONTEND_TYPECHECK="TODO_FRONTEND_TYPECHECK_COMMAND"
FRONTEND_TEST_CMD="TODO_FRONTEND_TEST_COMMAND"
FRONTEND_LINT="TODO_FRONTEND_LINT_COMMAND"

if has_file "package.json"; then
  FRONTEND_LANG="JavaScript/TypeScript"
  FRONTEND_REPO="."
  PKG_JSON="$(cat "$ROOT/package.json")"
  if echo "$PKG_JSON" | grep -q '"vue"'; then FRONTEND_FRAMEWORK="Vue"
  elif echo "$PKG_JSON" | grep -q '"react"'; then FRONTEND_FRAMEWORK="React"
  elif echo "$PKG_JSON" | grep -q '"next"'; then FRONTEND_FRAMEWORK="Next.js"
  else FRONTEND_FRAMEWORK="Node/Web"
  fi

  if has_file "pnpm-lock.yaml"; then PM="pnpm"
  elif has_file "yarn.lock"; then PM="yarn"
  else PM="npm run"
  fi

  if echo "$PKG_JSON" | grep -q '"type-check"'; then FRONTEND_TYPECHECK="$PM type-check"; fi
  if echo "$PKG_JSON" | grep -q '"test"'; then FRONTEND_TEST_CMD="$PM test"; fi
  if echo "$PKG_JSON" | grep -q '"lint"'; then FRONTEND_LINT="$PM lint"; fi
fi

# ──────────────────────────────────────────────
# Step 2: Interactive configuration
# ──────────────────────────────────────────────

ask_question() {
  local prompt="$1" default="$2" options="$3"
  if [ "$NON_INTERACTIVE" = true ]; then echo "$default"; return; fi
  local opt_text=""
  [ -n "$options" ] && opt_text=" ($options)"
  local def_text=""
  [ -n "$default" ] && def_text=" [$default]"
  read -r -p "${prompt}${opt_text}${def_text}: " response
  if [ -z "$response" ]; then echo "$default"; return; fi
  if [ -n "$options" ]; then
    local valid=false
    for o in $(echo "$options" | tr '/' ' '); do
      [ "$response" = "$o" ] && valid=true
    done
    if [ "$valid" = false ]; then
      echo -e "${YELLOW}  Please choose from: $options${NC}" >&2
      ask_question "$prompt" "$default" "$options"
      return
    fi
  fi
  echo "$response"
}

ask_yes_no() {
  local prompt="$1" default="$2"
  if [ "$NON_INTERACTIVE" = true ]; then echo "$default"; return; fi
  local hint="y/N"
  [ "$default" = true ] && hint="Y/n"
  read -r -p "${prompt} (${hint}): " response
  if [ -z "$response" ]; then echo "$default"; return; fi
  case "$response" in [yY]|[yY][eE][sS]) echo true;; *) echo false;; esac
}

echo -e "\n${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   agent-flow Project Initialization     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo -e "Project: ${GREEN}$PROJECT_NAME${NC}\n"

DB_ENGINE=$(ask_question "Database engine" "none" "none/PostgreSQL/MySQL/SQLite/MongoDB/Redis/Other")
CACHE_ENGINE=$(ask_question "Cache engine" "none" "none/Redis/Memcached/Local/Other")
AUTH_ENGINE=$(ask_question "Auth engine" "none" "none/JWT/Session/OAuth/SaaS/Other")
FE_VERIFY=$(ask_yes_no "Will changes affect user-visible UI?" true)
SCHEMA_CHANGE=$(ask_yes_no "Does this project modify database schema?" false)
TDD_MODE=$(ask_yes_no "Enforce TDD (test-first) for all code?" true)

echo -e "\n${GREEN}Configuration summary:${NC}"
echo "  Database : $DB_ENGINE"
echo "  Cache    : $CACHE_ENGINE"
echo "  Auth     : $AUTH_ENGINE"
echo "  Frontend verification : $( [ "$FE_VERIFY" = true ] && echo Yes || echo No )"
echo "  Schema changes        : $( [ "$SCHEMA_CHANGE" = true ] && echo Yes || echo No )"
echo "  TDD enforced          : $( [ "$TDD_MODE" = true ] && echo Yes || echo No )"

CONFIRM=$(ask_yes_no "Apply this configuration?" true)
if [ "$CONFIRM" != true ]; then
  echo -e "${YELLOW}Initialization cancelled.${NC}"
  exit 0
fi

# ──────────────────────────────────────────────
# Step 3: Generate configuration files
# ──────────────────────────────────────────────

BACKEND_ENTRY=$(existing_dirs "src" "app" "server" "backend" "cmd" "internal")
COMMON=$(existing_dirs "common" "shared" "lib" "libs" "utils" "core" "packages")
BUSINESS=$(existing_dirs "modules" "services" "features" "apps" "packages" "src")
TESTS=$(existing_dirs "test" "tests" "src/test" "__tests__")
SQL_PATHS=$(existing_dirs "migrations" "schema" "sql" "db" "database" "prisma")

[ -z "$BACKEND_ENTRY" ] && BACKEND_ENTRY="TODO_BACKEND_ENTRY"
[ -z "$COMMON" ] && COMMON="TODO_COMMON_CODE_PATH"
[ -z "$BUSINESS" ] && BUSINESS="TODO_BUSINESS_MODULE_PATH"
[ -z "$TESTS" ] && TESTS="TODO_TEST_PATH"
[ -z "$SQL_PATHS" ] && SQL_PATHS="TODO_SQL_PATH"

BUILD_FILES=""
for f in "package.json" "pnpm-workspace.yaml" "tsconfig.json" "vite.config.ts" "pom.xml" "build.gradle" "pyproject.toml" "go.mod" "Cargo.toml"; do
  has_file "$f" && BUILD_FILES="$BUILD_FILES\n  - $f"
done
[ -z "$BUILD_FILES" ] && BUILD_FILES="\n  - TODO_BUILD_FILE"

HEAVY_RULES=""
for rule in "new_module_or_package" \
  $( [ "$SCHEMA_CHANGE" = true ] && echo "schema_change" ) \
  "auth_or_permission_change" "public_api_change" "state_machine_change" \
  "cache_or_token_change" "websocket_or_realtime_change" "workflow_change" \
  "cross_repo_frontend_backend" "deployment_or_production_config" "production_incident_risk"; do
  [ -n "$rule" ] && HEAVY_RULES="$HEAVY_RULES\n    - $rule"
done

yaml_list() {
  local indent="$1"; shift
  for item in "$@"; do echo "$indent- $item"; done
}

GATES_FILE="$ROOT/agent-flow/rules/gates.txt"
if [ ! -f "$GATES_FILE" ]; then
  echo "Gate registry not found: $GATES_FILE" >&2
  exit 1
fi
GATE_LINES=$(grep -Ev '^\s*(#|$)' "$GATES_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^/  - /')

# Write manifest.yaml
MANIFEST="$ROOT/agent-flow/manifest.yaml"
cat > "$MANIFEST" <<MANIFESTEOF
project:
  name: $PROJECT_NAME
  kind: initialized
  backend:
    framework: $BACKEND_FRAMEWORK
    language: $BACKEND_LANG
    build: $BUILD
    root_module: $PROJECT_NAME
  frontend:
    framework: $FRONTEND_FRAMEWORK
    language: $FRONTEND_LANG
    repo: $FRONTEND_REPO
    verify_required: $([ "$FE_VERIFY" = true ] && echo true || echo false)
  database:
    engine: $DB_ENGINE
    sql_paths:
$(yaml_list "      " $SQL_PATHS)
  cache:
    engine: $CACHE_ENGINE
  auth:
    engine: $AUTH_ENGINE

code_map:
  backend_entry:
$(yaml_list "    " $BACKEND_ENTRY)
  common:
$(yaml_list "    " $COMMON)
  business_modules:
$(yaml_list "    " $BUSINESS)
  build_files:$BUILD_FILES
  tests:
$(yaml_list "    " $TESTS)

change_storage:
  root: agent-flow/changes
  knowledge: agent-flow/knowledge
  decisions: agent-flow/decisions
  reports: agent-flow/reports

risk_rules:
  heavy_if:$HEAVY_RULES
  destructive_gate:
    delete_lines_gte: 5
    public_contract_change: true
    build_file_change: true
    schema_change: $([ "$SCHEMA_CHANGE" = true ] && echo true || echo false)
  blocked_if:
    - hard_delete_without_approval
    - disable_security_filter
    - bypass_auth_for_production
    - direct_production_data_mutation
    - payment_bypass

verification:
  backend_compile: $BACKEND_COMPILE
  backend_test: $BACKEND_TEST
  module_compile: $MODULE_COMPILE
  module_test: $MODULE_TEST
  frontend_typecheck: $FRONTEND_TYPECHECK
  frontend_test: $FRONTEND_TEST_CMD
  frontend_lint: $FRONTEND_LINT
  tdd_enforced: $([ "$TDD_MODE" = true ] && echo true || echo false)

gates:
$GATE_LINES
MANIFESTEOF

# Write module-map.md
{
  echo "# Module Map"
  echo ""
  echo "## Current Modules"
  echo ""
  echo "| Module | Path | Responsibility | Notes |"
  echo "|---|---|---|---|"
  for d in $BUSINESS; do echo "| $(basename "$d") | \`$d\` | TODO | initialized |"; done
  echo ""
  echo "## Entry Points"
  echo ""
  echo "| Entry | Path | Purpose |"
  echo "|---|---|---|"
  for d in $BACKEND_ENTRY; do echo "| $(basename "$d") | \`$d\` | TODO |"; done
  echo ""
  echo "## New Module Registry"
  echo ""
  echo "| Module | Path | Responsibility | Registration Point | Change |"
  echo "|---|---|---|---|---|"
} > "$ROOT/agent-flow/knowledge/module-map.md"

# Write reuse-map.md
{
  echo "# Reuse Map"
  echo ""
  echo "> Before writing new code, check here, then check the codebase. Add new reusable discoveries after each change."
  echo ""
  echo "| Capability | Existing Location | How To Reuse | Notes |"
  echo "|---|---|---|---|"
  echo "| Project common code | $COMMON | Scan before adding new helpers | initialized |"
} > "$ROOT/agent-flow/knowledge/reuse-map.md"

# Update AGENTS.md project context
AGENTS_FILE="$ROOT/AGENTS.md"
if [ -f "$AGENTS_FILE" ]; then
  TDD_TEXT="Optional"
  [ "$TDD_MODE" = true ] && TDD_TEXT="Enforced — test-first required"
  NEW_CONTEXT="## Project Context

- Project name: $PROJECT_NAME
- Backend: $BACKEND_LANG / $BACKEND_FRAMEWORK / $BUILD
- Frontend: $FRONTEND_LANG / $FRONTEND_FRAMEWORK
- Database: $DB_ENGINE
- Auth: $AUTH_ENGINE
- Cache: $CACHE_ENGINE
- Backend entries: $(echo $BACKEND_ENTRY | tr '\n' ', ')
- Common/shared paths: $(echo $COMMON | tr '\n' ', ')
- Business modules: $(echo $BUSINESS | tr '\n' ', ')
- Build files: $(echo $BUILD_FILES | tr '\n' ', ')
- Tests: $(echo $TESTS | tr '\n' ', ')
- Database/schema paths: $(echo $SQL_PATHS | tr '\n' ', ')
- TDD mode: $TDD_TEXT
- Protected areas: schema, auth/permission, public API contracts, build/module registration, deployment, destructive data operations

## Default Workflow"
  # Replace project context block
  awk -v new="$NEW_CONTEXT" '
    /^## Project Context/ { in_block=1; print new; next }
    /^## Default Workflow/ && in_block { in_block=0; next }
    !in_block { print }
  ' "$AGENTS_FILE" > "${AGENTS_FILE}.tmp" && mv "${AGENTS_FILE}.tmp" "$AGENTS_FILE"
fi

# Run scaffold health
bash "$ROOT/agent-flow/scripts/scaffold-health.sh"

echo -e "\n${GREEN}✅ agent-flow initialized for $PROJECT_NAME${NC}"
echo -e ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Review agent-flow/manifest.yaml — check TODO items"
echo "  2. Run: bash agent-flow/scripts/manifest-check.sh"
echo "  3. Run: bash agent-flow/scripts/scaffold-health.sh"
echo "  4. Start a change: bash agent-flow/scripts/new-change.sh --name my-feature --flow Standard"
echo "  5. Tell your AI: '按 agent-flow 流程处理这个需求：...'"
echo ""
