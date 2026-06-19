#!/usr/bin/env bash
set -euo pipefail

project_root="."
manifest="agent-flow/manifest.yaml"
strict_todo=false
todo_threshold=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    --manifest|-Manifest)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      manifest="$2"; shift 2 ;;
    --strict-todo|-StrictTodo)
      strict_todo=true; shift ;;
    --todo-threshold|-TodoThreshold)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      todo_threshold="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: manifest-check.sh [--project-root <path>] [--manifest agent-flow/manifest.yaml] [--strict-todo] [--todo-threshold <N>]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

project_root="$(cd "$project_root" 2>/dev/null && pwd || echo "$project_root")"
manifest_path="$project_root/$manifest"
if [ ! -f "$manifest_path" ]; then
  echo "Manifest not found: $manifest_path" >&2
  exit 2
fi
manifest_check_path="$(mktemp)"
trap 'rm -f "$manifest_check_path"' EXIT
LC_ALL=C sed '1s/^\xEF\xBB\xBF//' "$manifest_path" > "$manifest_check_path"

issues=()
warnings=()
todo_placeholders=()
todo_lines=()

todo_category() {
  case "$1" in
    *_COMMAND) echo "verification commands" ;;
    *_OR_NONE) echo "explicit none decisions" ;;
    *_PATH|*_ENTRY|*_MODULE|*_BUILD_FILE|*_TEST_PATH|*_COMMON_CODE_PATH) echo "project map paths" ;;
    *) echo "review manually" ;;
  esac
}

collect_todos() {
  local line_no=0 line placeholder
  while IFS= read -r line || [ -n "$line" ]; do
    line_no=$((line_no + 1))
    while IFS= read -r placeholder; do
      [ -n "$placeholder" ] || continue
      todo_placeholders+=("$placeholder")
      todo_lines+=("$line_no: ${line#"${line%%[![:space:]]*}"}")
    done < <(printf '%s\n' "$line" | grep -Eo 'TODO_[A-Z0-9_]+' || true)
  done < "$manifest_check_path"
}

write_todo_guidance() {
  if [ "${#todo_placeholders[@]}" -eq 0 ]; then
    return
  fi

  echo
  echo "Manifest TODO guidance:"
  local category i found
  for category in "project map paths" "verification commands" "explicit none decisions" "review manually"; do
    found=false
    for i in "${!todo_placeholders[@]}"; do
      if [ "$(todo_category "${todo_placeholders[$i]}")" = "$category" ]; then
        if [ "$found" = false ]; then
          echo " - $category:"
          found=true
        fi
        echo "   * ${todo_placeholders[$i]} at line ${todo_lines[$i]}"
      fi
    done
  done
  echo "Next steps:"
  echo "  1. Run init-project after the project skeleton and build files exist."
  echo "  2. Replace TODO_* values with concrete paths, commands, or explicit none/N/A."
  echo "  3. Use --strict-todo in CI only after project context is expected to be fully initialized."
}

public_script_entries() {
  local scripts_dir="$project_root/agent-flow/scripts"
  local entries=()
  local script base
  if [ ! -d "$scripts_dir" ]; then
    return
  fi
  for script in "$scripts_dir"/*.ps1 "$scripts_dir"/*.sh; do
    [ -f "$script" ] || continue
    base="$(basename "$script")"
    case "$base" in
      _*) continue ;;
    esac
    entries+=("agent-flow/scripts/$base")
  done
  if [ "${#entries[@]}" -gt 0 ]; then
    printf '%s\n' "${entries[@]}" | sort -u
  fi
}

require_text() {
  local label="$1" pattern="$2"
  if ! grep -Eq "$pattern" "$manifest_check_path"; then
    issues+=("Missing $label")
  fi
}

for section in project code_map change_storage risk_rules verification gates; do
  require_text "section: $section" "^$section:"
done

for rule in heavy_if destructive_gate blocked_if; do
  require_text "risk_rules.$rule" "^[[:space:]]+$rule:"
done

required_blocked=(
  hard_delete_without_approval
  disable_security_filter
  bypass_auth_for_production
  direct_production_data_mutation
  payment_bypass
)
for rule in "${required_blocked[@]}"; do
  require_text "blocked_if rule: $rule" "^[[:space:]]*-[[:space:]]+$rule([[:space:]]+#.*)?[[:space:]]*$"
done

gate_rules_path="$project_root/agent-flow/rules/gates.txt"
gate_rules_found=false
if [ -f "$gate_rules_path" ]; then
  gate_rules_found=true
  mapfile -t required_gates < <(grep -Ev '^[[:space:]]*(#|$)' "$gate_rules_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u)
else
  warnings+=("agent-flow/rules/gates.txt not found; deriving public scripts from agent-flow/scripts.")
  mapfile -t required_gates < <(public_script_entries)
fi

mapfile -t public_scripts < <(public_script_entries)
if [ "$gate_rules_found" = true ]; then
  for script in "${public_scripts[@]}"; do
    found=false
    for gate in "${required_gates[@]}"; do
      if [ "$gate" = "$script" ]; then
        found=true
        break
      fi
    done
    if [ "$found" = false ]; then
      issues+=("Public script missing from gate registry: $script")
    fi
  done
fi

mapfile -t manifest_gates < <(
  grep -E '^[[:space:]]*-[[:space:]]+agent-flow/scripts/[^[:space:]#]+[[:space:]]*$' "$manifest_check_path" |
    sed -E 's/^[[:space:]]*-[[:space:]]+//;s/[[:space:]]*$//' |
    sort -u
)
for entry in "${manifest_gates[@]}"; do
  found=false
  for gate in "${required_gates[@]}"; do
    if [ "$gate" = "$entry" ]; then
      found=true
      break
    fi
  done
  if [ "$found" = false ]; then
    issues+=("Manifest gate entry missing from gate registry: $entry")
  fi
done

for gate in "${required_gates[@]}"; do
  require_text "gate entry: $gate" "^[[:space:]]*-[[:space:]]+$gate[[:space:]]*$"
  if [ ! -f "$project_root/$gate" ]; then
    issues+=("Gate file does not exist: $gate")
  fi
done

collect_todos
todo_count="${#todo_placeholders[@]}"
if [ "$todo_count" -gt 0 ]; then
  message="Manifest has $todo_count unresolved TODO_ value(s)."
  if [ "$strict_todo" = true ]; then
    issues+=("$message")
  elif [ "$todo_threshold" -gt 0 ] && [ "$todo_count" -gt "$todo_threshold" ]; then
    issues+=("$message (threshold: $todo_threshold)")
  else
    warnings+=("$message")
  fi
fi

if [ "${#warnings[@]}" -gt 0 ]; then
  echo "Manifest warnings:"
  printf ' - %s\n' "${warnings[@]}"
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Manifest check failed:"
  printf ' - %s\n' "${issues[@]}"
  write_todo_guidance
  exit 2
fi

write_todo_guidance
echo "Manifest check passed."
