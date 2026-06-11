#!/usr/bin/env bash
set -euo pipefail

change_dir=""
all=false
changes_root="agent-flow/changes"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      change_dir="$2"
      shift 2
      ;;
    --all|-All)
      all=true
      shift
      ;;
    --changes-root|-ChangesRoot)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      changes_root="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: agent-flow/scripts/next-step.sh --change-dir <change-dir>
       agent-flow/scripts/next-step.sh --all [--changes-root agent-flow/changes]

Outputs the current agent-flow stage and a copyable next prompt.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

meaningful_file() {
  local file="$1"
  shift || true
  [ -f "$file" ] || return 1
  [ -s "$file" ] || return 1
  local text
  text="$(cat "$file")"
  [ -n "${text//[[:space:]]/}" ] || return 1
  for placeholder in "$@"; do
    if grep -Fq "$placeholder" "$file"; then
      return 1
    fi
  done
  return 0
}

flow_level() {
  local dir="$1"
  local file="$dir/CHANGE.md"
  if [ ! -f "$file" ]; then
    echo "Unknown"
  elif grep -Eiq '\[x\][[:space:]]+Heavy' "$file"; then
    echo "Heavy"
  elif grep -Eiq '\[x\][[:space:]]+Standard' "$file"; then
    echo "Standard"
  elif grep -Eiq '\[x\][[:space:]]+Light' "$file"; then
    echo "Light"
  else
    echo "Unknown"
  fi
}

audit_verdict() {
  local file="$1"
  local section="$2"
  [ -f "$file" ] || return 0
  awk -v section="$section" '
    $0 ~ "^## " section { in_section = 1; next }
    in_section && /^## / { in_section = 0 }
    in_section && /Verdict:/ {
      value = $0
      sub(/^.*Verdict:[[:space:]]*/, "", value)
      sub(/[[:space:]].*$/, "", value)
      print tolower(value)
      exit
    }
  ' "$file"
}

design_alignment_verdict() {
  local file="$1"
  [ -f "$file" ] || return 0
  awk '
    BEGIN { IGNORECASE = 1 }
    /^[[:space:]]*Alignment Verdict:[[:space:]]*/ {
      value = $0
      sub(/^.*Alignment Verdict:[[:space:]]*/, "", value)
      sub(/[[:space:]].*$/, "", value)
      print tolower(value)
      exit
    }
  ' "$file"
}

state_value() {
  local file="$1"
  local key="$2"
  [ -f "$file" ] || return 0
  awk -v key="$key" '
    $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
      value = $0
      sub("^[[:space:]]*" key ":[[:space:]]*", "", value)
      print value
      exit
    }
  ' "$file"
}

contains_item() {
  local needle="$1"
  shift || true
  local item
  for item in "$@"; do
    [ "$item" = "$needle" ] && return 0
  done
  return 1
}

json_array() {
  if [ "$#" -eq 0 ]; then
    printf '[]'
    return
  fi
  printf '['
  local first=true
  local item
  for item in "$@"; do
    if [ "$first" = false ]; then printf ','; fi
    first=false
    printf '"%s"' "$(json_string "$item")"
  done
  printf ']'
}

json_string() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

analyze_change() {
  local dir="$1"
  [ -d "$dir" ] || { echo "ChangeDir not found: $dir" >&2; exit 1; }

  local change_id flow stage next prompt plan_verdict closure_verdict alignment_verdict state_current_stage state_next_action
  change_id="$(basename "$dir")"
  flow="$(flow_level "$dir")"
  stage="unknown"
  next=""
  prompt=""
  state_current_stage="$(state_value "$dir/STATE.md" "current_stage")"
  state_next_action="$(state_value "$dir/STATE.md" "next_action")"
  local missing=()
  local blocked=()

  local file
  for file in STATE.md CHANGE.md CODE_SCAN.md VERIFY.md REPORT.md; do
    if ! meaningful_file "$dir/$file" "Status: not started" "No implementation verification has run yet"; then
      missing+=("$file")
    fi
  done

  if [ "$flow" = "Unknown" ]; then
    stage="intake"
    next="Confirm Light / Standard / Heavy and complete CHANGE.md."
    prompt="Continue agent-flow change: $change_id. Read the existing artifacts, confirm the flow level as Light/Standard/Heavy, and complete CHANGE.md. Do not implement code yet."
  elif contains_item "CHANGE.md" "${missing[@]}"; then
    stage="intake"
    next="Complete CHANGE.md."
    prompt="Continue agent-flow change: $change_id. Complete CHANGE.md with summary, goals, non-goals, impact, risks, and flow level."
  elif contains_item "CODE_SCAN.md" "${missing[@]}"; then
    stage="code-scan"
    next="Run code-first scan and complete CODE_SCAN.md."
    prompt="Continue agent-flow change: $change_id. Run a code-first scan and complete CODE_SCAN.md with related modules, similar implementations, reusable abstractions, read_files, write_files, and open questions. Do not implement code yet."
  elif [ "$flow" = "Light" ]; then
    if contains_item "VERIFY.md" "${missing[@]}"; then
      stage="verify"
      next="Run verification and complete VERIFY.md."
      prompt="Continue agent-flow change: $change_id. Run the relevant verification commands, complete VERIFY.md, and record AC evidence, skipped checks, and conclusions."
    elif contains_item "REPORT.md" "${missing[@]}"; then
      stage="report"
      next="Complete REPORT.md and close out."
      prompt="Continue agent-flow change: $change_id. Complete REPORT.md from CHANGE, CODE_SCAN, and VERIFY, including delivered changes, verification results, and residual risks."
    else
      stage="complete-or-review"
      next="Light artifacts are ready. Review manually, then close or record reusable lessons in EVOLUTION.md."
      prompt="Continue agent-flow change: $change_id. Review whether this Light change meets the definition of done, and record reusable lessons in knowledge or EVOLUTION if useful."
    fi
  else
    for file in REQUIREMENT.md DESIGN.md TASKS.md EVOLUTION.md; do
      if ! meaningful_file "$dir/$file" "Status: not started" "TODO"; then
        missing+=("$file")
      fi
    done
    if [ "$flow" = "Heavy" ]; then
      for file in PLAN.md AUDIT.md REVIEW.md; do
        if ! meaningful_file "$dir/$file" "Status: not run" "not run"; then
          missing+=("$file")
        fi
      done
    fi

    plan_verdict="$(audit_verdict "$dir/AUDIT.md" "Plan Audit")"
    closure_verdict="$(audit_verdict "$dir/AUDIT.md" "Closure Audit")"
    alignment_verdict="$(design_alignment_verdict "$dir/DESIGN.md")"

    if contains_item "REQUIREMENT.md" "${missing[@]}"; then
      stage="requirement"
      next="Complete REQUIREMENT.md with AC-01 style acceptance criteria."
      prompt="Continue agent-flow change: $change_id. Based on CHANGE and CODE_SCAN, complete REQUIREMENT.md. Acceptance criteria must use AC-01, AC-02 style IDs. Do not implement code yet."
    elif contains_item "DESIGN.md" "${missing[@]}"; then
      stage="design"
      next="Complete DESIGN.md with API / Permission / Auth decisions."
      prompt="Continue agent-flow change: $change_id. Based on REQUIREMENT and CODE_SCAN, complete DESIGN.md with module boundaries, reusable abstractions, API/Permission/Auth decisions, test strategy, and risks. Do not implement code yet."
    elif [ "$alignment_verdict" != "aligned" ] && [ "$alignment_verdict" != "skipped" ]; then
      stage="design-alignment"
      if [ "$alignment_verdict" = "blocked" ]; then
        blocked+=("Design Alignment is blocked; resolve open questions before planning or implementation.")
      fi
      next="Run Design Alignment / Grill before PLAN.md, TASKS.md, or implementation."
      prompt="Continue agent-flow change: $change_id. Run Design Alignment / Grill before planning or implementation. Read REQUIREMENT.md, CODE_SCAN.md, and DESIGN.md. Interview me one question at a time until user intent, code facts, and the design are aligned. If a question can be answered by reading the codebase, read the codebase instead of asking me. For every question, provide your recommended answer. After each confirmed answer, update DESIGN.md. Run alignment-check after updating DESIGN.md. Do not create PLAN.md, TASKS.md, or implement code until Alignment Verdict is aligned or I explicitly accept skipped with Skip Reason."
    elif [ "$flow" = "Heavy" ] && contains_item "PLAN.md" "${missing[@]}"; then
      stage="plan"
      next="Complete PLAN.md."
      prompt="Continue agent-flow change: $change_id. Based on REQUIREMENT, CODE_SCAN, and DESIGN, complete PLAN.md with Current Baseline, Execution Phases, Closure Gates, and Protected Area Review."
    elif contains_item "TASKS.md" "${missing[@]}"; then
      stage="tasks"
      next="Complete TASKS.md with Task Matrix, status, read_files, and write_files."
      prompt="Continue agent-flow change: $change_id. Based on DESIGN, complete TASKS.md. Include a Task Matrix. Each task must include status, goal, AC mapping, read_files, write_files, verification command, and parallelization status. Then run task-check."
    elif [ "$flow" = "Heavy" ] && [ "$plan_verdict" != "accept" ] && [ "$plan_verdict" != "conditional" ]; then
      stage="plan-audit"
      next="Run Plan Audit."
      prompt="Continue agent-flow change: $change_id. Run Plan Audit against REQUIREMENT, CODE_SCAN, DESIGN, PLAN, and TASKS. Check consistency and protected areas. If verdict is not accept, stop and list required fixes."
    elif contains_item "VERIFY.md" "${missing[@]}"; then
      stage="verify"
      next="Run verification and complete VERIFY.md."
      prompt="Continue agent-flow change: $change_id. Run the relevant verification commands and complete VERIFY.md with command log, AC evidence, scan-check, task-check, code-drift-check, blocked-check, task-boundary-check, manifest-check, skipped checks, and conclusion."
    elif [ "$flow" = "Heavy" ] && contains_item "REVIEW.md" "${missing[@]}"; then
      stage="review"
      next="Complete REVIEW.md."
      prompt="Continue agent-flow change: $change_id. Complete REVIEW.md from intent compliance, architecture compliance, code quality, and verification evidence."
    elif contains_item "REPORT.md" "${missing[@]}"; then
      stage="report"
      next="Complete REPORT.md."
      prompt="Continue agent-flow change: $change_id. Complete REPORT.md with delivered changes, verification results, residual risks, rollback advice, and follow-up items."
    elif [ "$flow" = "Heavy" ] && [ "$closure_verdict" != "acceptable" ] && [ "$closure_verdict" != "accept" ] && [ "$closure_verdict" != "conditional" ]; then
      stage="closure-audit"
      next="Run Closure Audit."
      prompt="Continue agent-flow change: $change_id. Run Closure Audit. Check Closure Gates, VERIFY evidence, AC coverage, scan-check, task-check, code-drift-check, blocked-check, task-boundary-check, manifest-check, evolution-check, closure-check, and knowledge/decision/log/baseline updates."
    elif contains_item "EVOLUTION.md" "${missing[@]}"; then
      stage="evolution"
      next="Complete EVOLUTION.md and evaluate whether agent-flow should be upgraded."
      prompt="Continue agent-flow change: $change_id. Complete EVOLUTION.md and evaluate whether templates, scripts, knowledge, flows, or AGENTS.md should be upgraded. Only evaluate; do not edit framework files yet."
    else
      stage="complete-or-conditional"
      if [ "$closure_verdict" = "conditional" ]; then
        blocked+=("Closure Audit is conditional; decide whether to accept residual risk or add more verification.")
        next="Accept conditional closure or add verification to reach acceptable closure."
        prompt="Continue agent-flow change: $change_id. Read AUDIT, VERIFY, and REPORT, list residual risks from conditional closure, and propose two options: accept risk or add verification. Do not edit files."
      else
        next="Artifacts are ready. Review manually, then close the change."
        prompt="Continue agent-flow change: $change_id. Do a final read-only review, confirm whether the definition of done is met, and output the closeout summary."
      fi
    fi
  fi

  printf '{\n'
  printf '  "change_id": "%s",\n' "$(json_string "$change_id")"
  printf '  "flow": "%s",\n' "$(json_string "$flow")"
  printf '  "stage": "%s",\n' "$(json_string "$stage")"
  printf '  "state_current_stage": "%s",\n' "$(json_string "$state_current_stage")"
  printf '  "state_next_action": "%s",\n' "$(json_string "$state_next_action")"
  printf '  "missing": %s,\n' "$(json_array "${missing[@]}")"
  printf '  "blocked": %s,\n' "$(json_array "${blocked[@]}")"
  printf '  "next": "%s",\n' "$(json_string "$next")"
  printf '  "next_prompt": "%s"\n' "$(json_string "$prompt")"
  printf '}'
}

if [ "$all" = true ]; then
  [ -d "$changes_root" ] || { echo "ChangesRoot not found: $changes_root" >&2; exit 1; }
  printf '[\n'
  first=true
  for dir in "$changes_root"/*; do
    [ -d "$dir" ] || continue
    if [ "$first" = false ]; then printf ',\n'; fi
    first=false
    analyze_change "$dir"
  done
  printf '\n]\n'
else
  if [ -z "$change_dir" ]; then
    echo "Use --change-dir <path> or --all." >&2
    exit 2
  fi
  analyze_change "$change_dir"
  printf '\n'
fi
