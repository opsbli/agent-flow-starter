#!/usr/bin/env bash
set -euo pipefail

change_dir=""
test_root="."

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
    --test-root|-TestRoot)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 2
      fi
      test_root="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: agent-flow/scripts/ac-check.sh --change-dir <change-dir> [--test-root <path>]

Checks that REQUIREMENT.md contains machine-readable AC ids and that each id
has evidence somewhere in *.java, *.ts, *.tsx, *.js, or *.md files.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$change_dir" ]; then
  echo "Missing required argument: --change-dir" >&2
  exit 2
fi

if [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 1
fi

requirement="$change_dir/REQUIREMENT.md"
if [ ! -f "$requirement" ]; then
  echo "REQUIREMENT.md not found in $change_dir" >&2
  exit 1
fi

mapfile -t acs < <(
  grep -Eoh 'AC[-_ ]?[0-9]{2,4}' "$requirement" \
    | tr '[:lower:]' '[:upper:]' \
    | sed -E 's/[ _]/-/g' \
    | sort -u
)

if [ "${#acs[@]}" -eq 0 ]; then
  echo "No AC ids found in $requirement" >&2
  exit 1
fi

missing=()
for ac in "${acs[@]}"; do
  compact="${ac//-/}"
  if ! grep -R -I -q -F --include='*.java' --include='*.ts' --include='*.tsx' --include='*.js' --include='*.md' "$ac" "$test_root" \
    && ! grep -R -I -q -F --include='*.java' --include='*.ts' --include='*.tsx' --include='*.js' --include='*.md' "$compact" "$test_root"; then
    missing+=("$ac")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Missing AC evidence:"
  printf ' - %s\n' "${missing[@]}"
  exit 2
fi

echo "AC check passed: ${#acs[@]} AC ids have evidence."
