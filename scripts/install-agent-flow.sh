#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
starter_root="$(cd "$script_dir/.." && pwd)"
installer="$starter_root/agent-flow/scripts/install-agent-flow.sh"

if [ ! -f "$installer" ]; then
  echo "Canonical installer not found: $installer" >&2
  exit 1
fi

bash "$installer" --starter-root "$starter_root" "$@"

# --- Post-install: ECC integration notice ---
echo ""
echo "=== ECC Integration (optional) ==="
if [ -d "$HOME/.pi/agent/npm/node_modules/ecc-universal" ]; then
  echo "  ECC detected on this system. Skills included:"
  echo "  - agent-flow/ecc-integration.md (skill mapping table)"
  echo "  - Use /af-scan, /af-design, /af-verify, /af-go in pi"
else
  echo "  ECC not detected. To enable ECC skills:"
  echo "    pi install npm:ecc-universal"
  echo "  Then re-run this installer to get ecc-integration.md"
fi
