#!/usr/bin/env bash
# Install git pre-commit hook that runs incremental-verify before each commit
# Usage: bash agent-flow/scripts/install-git-hooks.sh [--project-root <path>]
set -euo pipefail
project_root="${1:-.}"
hooks_dir="$project_root/.git/hooks"
hook_file="$hooks_dir/pre-commit"
[ ! -d "$hooks_dir" ] && { echo "No .git/hooks directory. Not a git repository?"; exit 1; }
cat > "$hook_file" << 'HOOKEOF'
#!/usr/bin/env sh
# agent-flow incremental-verify pre-commit hook
echo ""
echo "=== agent-flow: Running incremental verification ==="
script="$PWD/agent-flow/scripts/incremental-verify.sh"
if [ -f "$script" ]; then
  bash "$script"
  if [ $? -ne 0 ]; then
    echo "Verification failed. Commit blocked."
    echo "Use 'git commit --no-verify' to bypass."
    exit 1
  fi
fi
echo "Verification passed. Proceeding with commit."
exit 0
HOOKEOF
chmod +x "$hook_file"
echo "Pre-commit hook installed: $hook_file"
echo "It runs incremental-verify.sh before each commit."
echo "Use 'git commit --no-verify' to bypass."
