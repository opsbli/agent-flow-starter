#!/usr/bin/env bash
set -euo pipefail

change_dir=""
project_root="."
closure=false
json=false
output_path=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    --closure|-Closure)
      closure=true; shift ;;
    --json|-Json)
      json=true; shift ;;
    --output|-OutputPath)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      output_path="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: check-change.sh --change-dir <change-dir> [--project-root <path>] [--closure] [--json] [--output <path>]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ] || [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/_common.sh"
failed=0
results=()

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

add_result() {
  local name="$1" status="$2" required="$3" exit_code="$4" reason="${5:-}"
  results+=("$name|$status|$required|$exit_code|$reason")
}

run_gate() {
  local name="$1"; shift
  local output code status reason
  echo "== $name =="
  set +e
  output="$("$@" 2>&1)"
  code=$?
  set -e
  [ -z "$output" ] || printf '%s\n' "$output"
  status="pass"
  reason=""
  if printf '%s\n' "$output" | grep -Eiq '^[[:space:]]*SKIP:'; then
    status="skipped"
    reason="$(printf '%s\n' "$output" | grep -Ei '^[[:space:]]*SKIP:' | head -n 1 | xargs)"
  elif [ "$code" -ne 0 ]; then
    status="fail"
    reason="gate exited with code $code"
    echo "Gate failed: $name" >&2
    failed=1
  fi
  add_result "$name" "$status" true "$code" "$reason"
}

skip_gate() {
  local name="$1" reason="$2"
  add_result "$name" skipped false 0 "$reason"
}

has_file() {
  [ -f "$change_dir/$1" ]
}

required_closure_artifacts() {
  local flow="$1"
  case "$flow" in
    Light)
      printf '%s\n' STATE.md CHANGE.md CODE_SCAN.md VERIFY.md REPORT.md
      ;;
    Standard)
      printf '%s\n' STATE.md CHANGE.md REQUIREMENT.md CODE_SCAN.md DESIGN.md TASKS.md VERIFY.md REPORT.md EVOLUTION.md
      ;;
    Heavy)
      printf '%s\n' STATE.md CHANGE.md REQUIREMENT.md CODE_SCAN.md DESIGN.md PLAN.md TASKS.md VERIFY.md REVIEW.md REPORT.md AUDIT.md EVOLUTION.md
      ;;
    Emergency)
      printf '%s\n' STATE.md CHANGE.md TASKS.md VERIFY.md REPORT.md EVOLUTION.md
      ;;
  esac
}

run_closure_required_artifacts() {
  [ "$closure" = true ] || return 0

  echo "== closure-required-artifacts =="
  local flow
  flow="$(flow_level "$change_dir")"
  local issues=()
  if [ "$flow" = "Unknown" ]; then
    issues+=("Cannot determine flow level from CHANGE.md.")
  fi

  local artifact
  while IFS= read -r artifact; do
    [ -n "$artifact" ] || continue
    if ! meaningful_file "$change_dir/$artifact" "Status: not started" "No implementation verification has run yet" "YYYY-MM-DD" "path/to" "{name}"; then
      issues+=("Missing or placeholder closure artifact: $artifact")
    fi
  done < <(required_closure_artifacts "$flow")

  if [ "${#issues[@]}" -gt 0 ]; then
    for issue in "${issues[@]}"; do echo " - $issue"; done
    add_result closure-required-artifacts fail true 2 "missing required closure artifacts"
    failed=1
    return 0
  fi

  echo "closure-required-artifacts passed for $flow change."
  add_result closure-required-artifacts pass true 0 ""
}

write_summary() {
  local passed="false"
  [ "$failed" -eq 0 ] && passed="true"
  local generated_at
  generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local tmp
  tmp="$(mktemp)"
  {
    printf '{\n'
    printf '  "schema_version": "1.0",\n'
    printf '  "generated_at": "%s",\n' "$(json_escape "$generated_at")"
    printf '  "change_dir": "%s",\n' "$(json_escape "$change_dir")"
    printf '  "project_root": "%s",\n' "$(json_escape "$project_root")"
    printf '  "closure": %s,\n' "$closure"
    printf '  "passed": %s,\n' "$passed"
    printf '  "gates": [\n'
    local first=true entry name status required exit_code reason
    for entry in "${results[@]}"; do
      IFS='|' read -r name status required exit_code reason <<< "$entry"
      if [ "$first" = false ]; then printf ',\n'; fi
      first=false
      printf '    {"gate":"%s","status":"%s","required":%s,"exit_code":%s,"reason":"%s"}' \
        "$(json_escape "$name")" "$(json_escape "$status")" "$required" "$exit_code" "$(json_escape "$reason")"
    done
    printf '\n  ]\n'
    printf '}\n'
  } > "$tmp"
  if [ -n "$output_path" ]; then
    cp "$tmp" "$output_path"
    echo "Wrote check result: $output_path"
  fi
  if [ "$json" = true ]; then
    cat "$tmp"
  fi
  rm -f "$tmp"
}

run_gate sync-state bash "$script_dir/sync-state.sh" --change-dir "$change_dir"
run_gate state-check bash "$script_dir/state-check.sh" --change-dir "$change_dir"
run_closure_required_artifacts

if has_file CODE_SCAN.md; then
  run_gate scan-check bash "$script_dir/scan-check.sh" --change-dir "$change_dir" --project-root "$project_root" --strict
else
  skip_gate scan-check "CODE_SCAN.md not present"
fi

if has_file CHANGE.md; then
  run_gate emergency-check bash "$script_dir/emergency-check.sh" --change-dir "$change_dir"
else
  skip_gate emergency-check "CHANGE.md not present"
fi

if has_file DESIGN.md; then
  run_gate design-check bash "$script_dir/design-check.sh" --change-dir "$change_dir"
  run_gate alignment-check bash "$script_dir/alignment-check.sh" --change-dir "$change_dir"
else
  skip_gate design-check "DESIGN.md not present"
  skip_gate alignment-check "DESIGN.md not present"
fi

if has_file TASKS.md; then
  run_gate task-check bash "$script_dir/task-check.sh" --change-dir "$change_dir"
  run_gate task-boundary-check bash "$script_dir/task-boundary-check.sh" --change-dir "$change_dir" --project-root "$project_root"
else
  skip_gate task-check "TASKS.md not present"
  skip_gate task-boundary-check "TASKS.md not present"
fi

if has_file PLAN.md || has_file AUDIT.md; then
  run_gate plan-check bash "$script_dir/plan-check.sh" --change-dir "$change_dir"
else
  skip_gate plan-check "PLAN.md or AUDIT.md not present"
fi

if has_file REQUIREMENT.md && has_file VERIFY.md; then
  run_gate ac-check bash "$script_dir/ac-check.sh" --change-dir "$change_dir"
  run_gate ac-traceability-check bash "$script_dir/ac-traceability-check.sh" --change-dir "$change_dir"
  run_gate coverage-check bash "$script_dir/coverage-check.sh" --change-dir "$change_dir"
else
  skip_gate ac-check "REQUIREMENT.md or VERIFY.md not present"
  skip_gate ac-traceability-check "REQUIREMENT.md or VERIFY.md not present"
  skip_gate coverage-check "REQUIREMENT.md or VERIFY.md not present"
fi

if has_file DESIGN.md; then
  run_gate code-drift-check bash "$script_dir/code-drift-check.sh" --change-dir "$change_dir" --project-root "$project_root"
  run_gate api-compatibility-check bash "$script_dir/api-compatibility-check.sh" --change-dir "$change_dir" --project-root "$project_root"
  run_gate design-quality-check bash "$script_dir/design-quality-check.sh" --change-dir "$change_dir" --project-root "$project_root"
else
  skip_gate code-drift-check "DESIGN.md not present"
  skip_gate api-compatibility-check "DESIGN.md not present"
  skip_gate design-quality-check "DESIGN.md not present"
fi

if has_file TASKS.md; then
  run_gate blocked-check bash "$script_dir/blocked-check.sh" --change-dir "$change_dir" --project-root "$project_root"
  run_gate db-migration-check bash "$script_dir/db-migration-check.sh" --change-dir "$change_dir" --project-root "$project_root"
else
  skip_gate blocked-check "TASKS.md not present"
  skip_gate db-migration-check "TASKS.md not present"
fi

run_gate manifest-check bash "$script_dir/manifest-check.sh" --project-root "$project_root"

if has_file EVOLUTION.md; then
  run_gate evolution-check bash "$script_dir/evolution-check.sh" --change-dir "$change_dir"
else
  skip_gate evolution-check "EVOLUTION.md not present"
fi

if [ "$closure" = true ] || { has_file VERIFY.md && has_file REPORT.md; }; then
  run_gate closure-check bash "$script_dir/closure-check.sh" --change-dir "$change_dir" --project-root "$project_root"
else
  skip_gate closure-check "closure not requested and VERIFY.md/REPORT.md not both present"
fi

write_summary

if [ "$failed" -ne 0 ]; then
  echo "check-change failed." >&2
  exit 2
fi

echo "check-change passed."
