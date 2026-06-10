#!/usr/bin/env bash
# DEPRECATED: Use code-drift-check.sh instead, which compares DESIGN.md against actual code.
set -euo pipefail

echo "[DEPRECATED] Use code-drift-check.sh instead" >&2

change_dir=""

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
    -h|--help)
      cat <<'EOF'
Usage: agent-flow/scripts/drift-check.sh --change-dir <change-dir>

Checks DESIGN.md for common schema, route, and permission decision drift.
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

design="$change_dir/DESIGN.md"
if [ ! -f "$design" ]; then
  echo "DESIGN.md not found in $change_dir" >&2
  exit 1
fi

text="$(cat "$design")"
issues=()

if grep -Eq 'CREATE TABLE|ALTER TABLE|schema|数据设计' <<<"$text"; then
  if ! grep -Eq 'migrations|migration|schema|sql|prisma|liquibase|flyway|迁移|回滚' <<<"$text"; then
    issues+=("Design mentions schema/data changes but does not reference SQL migration or rollback.")
  fi
fi

if grep -Eq '@SaCheckPermission|权限|permission' <<<"$text"; then
  if ! grep -Eq '权限码|SaCheckPermission|匿名接口' <<<"$text"; then
    issues+=("Design mentions permission but lacks explicit permission-code or anonymous-interface decision.")
  fi
fi

if grep -Eq 'POST|GET|PUT|DELETE|路径|API' <<<"$text"; then
  if ! grep -Eq '/[a-zA-Z0-9{}_/:-]+' <<<"$text"; then
    issues+=("Design mentions API but no route-like path was found.")
  fi
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Drift check found issues:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Drift check passed."
