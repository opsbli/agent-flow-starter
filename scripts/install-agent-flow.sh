#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
starter_root="$(cd "$script_dir/.." && pwd)"
installer="$starter_root/agent-flow/scripts/install-agent-flow.sh"

if [ ! -f "$installer" ]; then
  echo "Canonical installer not found: $installer" >&2
  exit 1
fi

exec bash "$installer" --starter-root "$starter_root" "$@"
