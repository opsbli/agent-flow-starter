#!/usr/bin/env bash
set -euo pipefail

name=""
flow="Standard"
changes_root="agent-flow/changes"
template_root="agent-flow/templates"
force=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name|-Name)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      name="$2"
      shift 2
      ;;
    --flow|-Flow)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      flow="$2"
      shift 2
      ;;
    --changes-root|-ChangesRoot)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      changes_root="$2"
      shift 2
      ;;
    --template-root|-TemplateRoot)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      template_root="$2"
      shift 2
      ;;
    --force|-Force)
      force=true
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage: agent-flow/scripts/new-change.sh --name <change-name> [--flow Light|Standard|Heavy|Emergency]

Creates a change folder from templates and marks the selected flow in CHANGE.md.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$name" ]; then
  echo "Missing required argument: --name" >&2
  exit 2
fi

case "$flow" in
  Light|Standard|Heavy|Emergency) ;;
  *)
    echo "Flow must be Light, Standard, Heavy, or Emergency." >&2
    exit 2
    ;;
esac

slug="$(printf '%s' "$name" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[[:space:]_]+/-/g; s/[^a-z0-9-]//g; s/-+/-/g; s/^-//; s/-$//')"

if [ -z "$slug" ]; then
  echo "Name must contain at least one ASCII letter or number." >&2
  exit 2
fi

change_id="$(date '+%Y%m%d')-$slug"
# Auto prefix from manifest.yaml
manifest="$(dirname "$changes_root")/manifest.yaml"
project_prefix=""
if [ -f "$manifest" ]; then
  project_prefix="$(awk '/^name:/ { print; exit }' "$manifest" | sed 's/name:[[:space:]]*//' | sed 's/[^a-zA-Z0-9]//g')"
fi
[ -n "$project_prefix" ] && change_id="$(date '+%Y%m%d')-${project_prefix}-${slug}"

change_dir="$changes_root/$change_id"
if [ -e "$change_dir" ] && [ "$force" = false ]; then
  echo "Change already exists: $change_dir. Use --force to overwrite template files." >&2
  exit 1
fi

mkdir -p "$change_dir"

echo ""
echo "Created change: $change_id"
echo "   Flow level: $flow"
echo ""

case "$flow" in
  Light)
    files=(STATE.md CHANGE.md CODE_SCAN.md VERIFY.md REPORT.md)
    ;;
  Standard)
    files=(STATE.md CHANGE.md REQUIREMENT.md CODE_SCAN.md DESIGN.md TASKS.md VERIFY.md REPORT.md EVOLUTION.md)
    ;;
  Heavy)
    files=(STATE.md CHANGE.md REQUIREMENT.md CODE_SCAN.md DESIGN.md PLAN.md TASKS.md VERIFY.md REVIEW.md REPORT.md AUDIT.md EVOLUTION.md)
    ;;
  Emergency)
    files=(STATE.md CHANGE.md CODE_SCAN.md TASKS.md VERIFY.md REPORT.md EVOLUTION.md)
    ;;
esac

for file in "${files[@]}"; do
  source="$template_root/$file"
  target="$change_dir/$file"
  if [ ! -f "$source" ]; then
    echo "Template not found: $source" >&2
    exit 1
  fi
  if [ -e "$target" ] && [ "$force" = false ]; then
    continue
  fi
  sed -e "s/{change-id}/$slug/g" -e "s/{flow}/$flow/g" -e 's/{frontend-path}/TODO_FRONTEND_PATH_OR_NONE/g' "$source" > "$target"
  if [ "$file" = "CHANGE.md" ]; then
    tmp_target="$target.tmp"
    case "$flow" in
      Light)
        sed -E 's/- \[ \] Light/- [x] Light/' "$target" > "$tmp_target"
        ;;
      Standard)
        sed -E 's/- \[ \] Standard/- [x] Standard/' "$target" > "$tmp_target"
        ;;
      Heavy)
        sed -E 's/- \[ \] Heavy/- [x] Heavy/' "$target" > "$tmp_target"
        ;;
      Emergency)
        sed -E 's/- \[ \] Emergency/- [x] Emergency/' "$target" > "$tmp_target"
        ;;
    esac
    mv "$tmp_target" "$target"
  fi
done

echo "Created agent-flow change: $change_dir"
echo "Flow: $flow"
echo "Next: bash agent-flow/scripts/next-step.sh --change-dir $change_dir"
