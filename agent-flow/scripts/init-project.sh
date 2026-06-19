#!/usr/bin/env bash
set -euo pipefail

target="."
auto_fix=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target|-Target)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      target="$2"
      shift 2
      ;;
    --auto-fix|-AutoFix)
      auto_fix=true
      shift
      ;;
    -h|--help)
      echo "Usage: agent-flow/scripts/init-project.sh [--target <project-root>] [--auto-fix]"
      echo ""
      echo "  --auto-fix    Automatically infer and fill missing manifest values"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

root="$(cd "$target" && pwd)"
project_name="$(basename "$root")"

has_file() {
  [ -f "$root/$1" ]
}

existing_dirs() {
  local found=()
  for item in "$@"; do
    if [ -d "$root/$item" ]; then
      found+=("$item")
    fi
  done
  if [ "${#found[@]}" -gt 0 ]; then
    printf '%s\n' "${found[@]}"
  fi
}

build="unknown"
backend_framework="unknown"
backend_language="unknown"
backend_compile="TODO_BACKEND_COMPILE_COMMAND"
backend_test="TODO_BACKEND_TEST_COMMAND"
module_compile="TODO_MODULE_COMPILE_COMMAND"
module_test="TODO_MODULE_TEST_COMMAND"

if has_file "pom.xml"; then
  build="Maven"
  backend_framework="Java"
  backend_language="Java"
  backend_compile="mvn compile -DskipTests -q"
  backend_test="mvn test -q"
  module_compile="mvn compile -pl {module} -am -DskipTests -q"
  module_test="mvn test -pl {module} -am -q"
elif has_file "build.gradle" || has_file "settings.gradle" || has_file "build.gradle.kts"; then
  build="Gradle"
  backend_framework="Gradle project"
  backend_language="Java/Kotlin"
  backend_compile="./gradlew build -x test"
  backend_test="./gradlew test"
  module_compile="./gradlew :{module}:build -x test"
  module_test="./gradlew :{module}:test"
elif has_file "pyproject.toml" || has_file "requirements.txt"; then
  build="Python"
  backend_framework="Python"
  backend_language="Python"
  backend_compile="python -m compileall ."
  backend_test="pytest"
elif has_file "go.mod"; then
  build="Go"
  backend_framework="Go"
  backend_language="Go"
  backend_compile="go test ./... -run TestNonExistent"
  backend_test="go test ./..."
elif has_file "Cargo.toml"; then
  build="Cargo"
  backend_framework="Rust"
  backend_language="Rust"
  backend_compile="cargo check"
  backend_test="cargo test"
fi

frontend_framework="none"
frontend_language="none"
frontend_repo="none"
frontend_typecheck="TODO_FRONTEND_TYPECHECK_COMMAND"
frontend_test="TODO_FRONTEND_TEST_COMMAND"
frontend_lint="TODO_FRONTEND_LINT_COMMAND"

if has_file "package.json"; then
  frontend_language="JavaScript/TypeScript"
  frontend_repo="."
  package_text="$(cat "$root/package.json")"
  if grep -q '"vue"' <<<"$package_text"; then frontend_framework="Vue"
  elif grep -q '"react"' <<<"$package_text"; then frontend_framework="React"
  elif grep -q '"next"' <<<"$package_text"; then frontend_framework="Next.js"
  else frontend_framework="Node/Web"
  fi

  if has_file "pnpm-lock.yaml"; then pm="pnpm"
  elif has_file "yarn.lock"; then pm="yarn"
  else pm="npm run"
  fi

  if grep -q '"type-check"' <<<"$package_text"; then frontend_typecheck="$pm type-check"
  elif grep -q '"typecheck"' <<<"$package_text"; then frontend_typecheck="$pm typecheck"
  fi
  if grep -q '"test"' <<<"$package_text"; then frontend_test="$pm test"; fi
  if grep -q '"lint"' <<<"$package_text"; then frontend_lint="$pm lint"; fi
fi

frontend_candidates=()
for candidate in apps/web apps/frontend web frontend client packages/web packages/frontend; do
  if has_file "$candidate/package.json"; then
    frontend_candidates+=("$candidate")
  fi
done
if [ "${#frontend_candidates[@]}" -gt 0 ]; then
  frontend_repo="${frontend_candidates[*]}"
elif has_file "pnpm-workspace.yaml"; then
  frontend_repo="workspace"
fi

mapfile -t backend_entry < <(existing_dirs src app server backend cmd internal)
mapfile -t common_paths < <(existing_dirs common shared lib libs utils core packages)
mapfile -t business_modules < <(existing_dirs modules services features apps packages src)
mapfile -t tests < <(existing_dirs test tests src/test __tests__)
mapfile -t sql_paths < <(existing_dirs migrations schema sql db database prisma)

if [ "${#backend_entry[@]}" -eq 0 ]; then backend_entry=("TODO_BACKEND_ENTRY"); fi
if [ "${#common_paths[@]}" -eq 0 ]; then common_paths=("TODO_COMMON_CODE_PATH"); fi
if [ "${#business_modules[@]}" -eq 0 ]; then business_modules=("TODO_BUSINESS_MODULE_PATH"); fi
if [ "${#tests[@]}" -eq 0 ]; then tests=("TODO_TEST_PATH"); fi
if [ "${#sql_paths[@]}" -eq 0 ]; then sql_paths=("TODO_SQL_PATH"); fi

build_files=()
for file in package.json pnpm-workspace.yaml pnpm-lock.yaml package-lock.json yarn.lock tsconfig.json vite.config.ts next.config.js pom.xml build.gradle settings.gradle pyproject.toml requirements.txt go.mod Cargo.toml; do
  if has_file "$file"; then build_files+=("$file"); fi
done
if [ "${#build_files[@]}" -eq 0 ]; then build_files=("TODO_BUILD_FILE"); fi

yaml_list() {
  local indent="$1"
  shift
  for item in "$@"; do
    printf '%s- %s\n' "$indent" "$item"
  done
}

gate_rules_path="$root/agent-flow/rules/gates.txt"
if [ ! -f "$gate_rules_path" ]; then
  echo "Gate registry not found: $gate_rules_path" >&2
  exit 2
fi
gate_lines="$(
  grep -Ev '^[[:space:]]*(#|$)' "$gate_rules_path" |
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^/  - /'
)"

cat > "$root/agent-flow/manifest.yaml" <<EOF
project:
  name: $project_name
  kind: initialized
  backend:
    framework: $backend_framework
    language: $backend_language
    build: $build
    root_module: $project_name
  frontend:
    framework: $frontend_framework
    language: $frontend_language
    repo: $frontend_repo
  database:
    engine: TODO_DATABASE_OR_NONE
    sql_paths:
$(yaml_list "      " "${sql_paths[@]}")
  cache:
    engine: TODO_CACHE_OR_NONE
  auth:
    engine: TODO_AUTH_OR_NONE

code_map:
  backend_entry:
$(yaml_list "    " "${backend_entry[@]}")
  common:
$(yaml_list "    " "${common_paths[@]}")
  business_modules:
$(yaml_list "    " "${business_modules[@]}")
  build_files:
$(yaml_list "    " "${build_files[@]}")
  tests:
$(yaml_list "    " "${tests[@]}")

change_storage:
  root: agent-flow/changes
  knowledge: agent-flow/knowledge
  decisions: agent-flow/decisions
  reports: agent-flow/reports

risk_rules:
  heavy_if:
    - new_module_or_package
    - schema_change
    - auth_or_permission_change
    - public_api_change
    - state_machine_change
    - cache_or_token_change
    - websocket_or_realtime_change
    - workflow_change
    - cross_repo_frontend_backend
    - deployment_or_production_config
    - production_incident_risk
  destructive_gate:
    delete_lines_gte: 5
    public_contract_change: true
    build_file_change: true
    schema_change: true
  blocked_if:
    - hard_delete_without_approval
    - disable_security_filter
    - bypass_auth_for_production
    - direct_production_data_mutation
    - payment_bypass

verification:
  backend_compile: $backend_compile
  backend_test: $backend_test
  module_compile: $module_compile
  module_test: $module_test
  frontend_typecheck: $frontend_typecheck
  frontend_test: $frontend_test
  frontend_lint: $frontend_lint

gates:
$gate_lines
EOF

{
  echo "# Module Map"
  echo
  echo "## Current Modules"
  echo
  echo "| Module | Path | Responsibility | Notes |"
  echo "|---|---|---|---|"
  for item in "${business_modules[@]}"; do
    echo "| $(basename "$item") | \`$item\` | TODO | initialized |"
  done
  echo
  echo "## Entry Points"
  echo
  echo "| Entry | Path | Purpose |"
  echo "|---|---|---|"
  for item in "${backend_entry[@]}"; do
    echo "| $(basename "$item") | \`$item\` | TODO |"
  done
  echo
  echo "## New Module Registry"
  echo
  echo "| Module | Path | Responsibility | Registration Point | Change |"
  echo "|---|---|---|---|---|"
} > "$root/agent-flow/knowledge/module-map.md"

cat > "$root/agent-flow/knowledge/reuse-map.md" <<EOF
# Reuse Map

> Before writing new code, check here, then check the codebase. Add new reusable discoveries after each change.

| Capability | Existing Location | How To Reuse | Notes |
|---|---|---|---|
| Project common code | ${common_paths[*]} | Scan before adding new helpers | initialized |
EOF

cat > "$root/agent-flow/knowledge/verification.md" <<EOF
# Verification Knowledge

## Backend

~~~text
$backend_compile
$backend_test
~~~

## Frontend

~~~text
$frontend_typecheck
$frontend_test
$frontend_lint
~~~

## Gates

Windows:

~~~powershell
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/manifest-check.ps1
agent-flow/scripts/scan-check.ps1 -ChangeDir agent-flow/changes/<change-id> -ProjectRoot . -Strict
agent-flow/scripts/design-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/alignment-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/task-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/plan-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/emergency-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/evolution-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<change-id> -OutputPath agent-flow/changes/<change-id>/CHECK_RESULT.json
agent-flow/scripts/run-verify.ps1 -All
~~~

Linux/macOS:

~~~bash
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/manifest-check.sh
bash agent-flow/scripts/scan-check.sh --change-dir agent-flow/changes/<change-id> --project-root . --strict
bash agent-flow/scripts/design-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/alignment-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/task-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/plan-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/emergency-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/evolution-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --output agent-flow/changes/<change-id>/CHECK_RESULT.json
bash agent-flow/scripts/run-verify.sh --all
~~~

## Evidence Requirement

\`VERIFY.md\` must record commands, results, failure summaries, skipped checks, AC evidence, and Machine Gate Summary rows with Result, Command, Exit Code, When, and Evidence.
EOF

agents_path="$root/AGENTS.md"
if [ -f "$agents_path" ]; then
  tmp_agents="$(mktemp)"
  awk \
    -v project="$project_name" \
    -v backend="$backend_language / $backend_framework / $build" \
    -v frontend="$frontend_language / $frontend_framework" \
    -v backend_entries="${backend_entry[*]}" \
    -v common="${common_paths[*]}" \
    -v modules="${business_modules[*]}" \
    -v builds="${build_files[*]}" \
    -v tests_text="${tests[*]}" \
    -v sql="${sql_paths[*]}" '
    BEGIN {
      context = "## Project Context\n\n" \
        "- Project name: " project "\n" \
        "- Backend: " backend "\n" \
        "- Frontend: " frontend "\n" \
        "- Backend entries: " backend_entries "\n" \
        "- Common/shared paths: " common "\n" \
        "- Business modules: " modules "\n" \
        "- Build files: " builds "\n" \
        "- Tests: " tests_text "\n" \
        "- Database/schema paths: " sql "\n" \
        "- Protected areas: schema, auth/permission, public API contracts, build/module registration, deployment, destructive data operations\n\n" \
        "## Default Workflow"
    }
    /^## Project Context$/ { print context; skipping = 1; next }
    /^## Default Workflow$/ { if (skipping) { skipping = 0; next } }
    !skipping { print }
  ' "$agents_path" > "$tmp_agents"
  mv "$tmp_agents" "$agents_path"
fi

# --- Auto-fix mode: infer missing manifest values ---
if [ "$auto_fix" = true ]; then
  manifest_path="$root/agent-flow/manifest.yaml"
  [ -f "$manifest_path" ] && grep -q "TODO_" "$manifest_path" && {
    echo ""
    echo "--- Auto-fix: inferring manifest values ---"
    # Database: check for migration files or SQL
    if grep -q "TODO_DATABASE_OR_NONE" "$manifest_path"; then
      if ls "$root"/migrations/*.sql "$root"/schema/*.sql 2>/dev/null | head -1 >/dev/null 2>&1; then
        sed -i 's/engine: TODO_DATABASE_OR_NONE/engine: auto-detected/' "$manifest_path"
      else
        sed -i 's/engine: TODO_DATABASE_OR_NONE/engine: none/' "$manifest_path"
      fi
      echo "  database.engine -> set"
    fi
    # Cache: check for redis config
    if grep -q "TODO_CACHE_OR_NONE" "$manifest_path"; then
      if ls "$root"/**/redis* "$root"/redis* 2>/dev/null | head -1 >/dev/null 2>&1; then
        sed -i 's/engine: TODO_CACHE_OR_NONE/engine: auto-detected/' "$manifest_path"
      else
        sed -i 's/engine: TODO_CACHE_OR_NONE/engine: none/' "$manifest_path"
      fi
      echo "  cache.engine -> set"
    fi
    # Auth
    if grep -q "TODO_AUTH_OR_NONE" "$manifest_path"; then
      if ls "$root"/**/SaToken* "$root"/**/Jwt* "$root"/**/Security* 2>/dev/null | head -1 >/dev/null 2>&1; then
        sed -i 's/engine: TODO_AUTH_OR_NONE/engine: auto-detected/' "$manifest_path"
      else
        sed -i 's/engine: TODO_AUTH_OR_NONE/engine: none/' "$manifest_path"
      fi
      echo "  auth.engine -> set"
    fi
    echo "Auto-fix complete. Run manifest-check to verify."
  }
fi

bash "$root/agent-flow/scripts/scaffold-health.sh"
echo "agent-flow initialized for $project_name"
