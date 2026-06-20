#!/usr/bin/env bash
set -euo pipefail
# pair-consistency-check.sh — detects line-count divergence between .ps1/.sh pairs

scripts_dir="agent-flow/scripts"
threshold_pct=30

while [ "$#" -gt 0 ]; do
  case "$1" in
    --scripts-dir|-ScriptsDir) scripts_dir="$2"; shift 2 ;;
    --threshold|-Threshold) threshold_pct="$2"; shift 2 ;;
    -h|--help)
      cat <<'EOF'
Usage: pair-consistency-check.sh [--scripts-dir <path>] [--threshold <pct>]

Checks .ps1/.sh script pairs for line-count divergence (> threshold%).
Also detects missing partner files and empty scripts.

Exit 0 if all pairs consistent; exit 2 if issues found.
EOF
      exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ ! -d "$scripts_dir" ]; then
  echo "Scripts directory not found: $scripts_dir" >&2
  exit 2
fi

issues=()
pairs=0
diverged=0

echo "=== Pair Consistency Check ==="
echo "Threshold: ${threshold_pct}% line count divergence"
echo ""

for ps1 in "$scripts_dir"/*.ps1; do
  [ -f "$ps1" ] || continue
  base=$(basename "$ps1" .ps1)
  [[ "$base" == _* ]] && continue

  sh="$scripts_dir/${base}.sh"
  if [ ! -f "$sh" ]; then
    issues+=("MISSING_PARTNER: $ps1 has no .sh counterpart")
    continue
  fi

  pairs=$((pairs + 1))
  ps1_lines=$(wc -l < "$ps1" 2>/dev/null || echo 0)
  sh_lines=$(wc -l < "$sh" 2>/dev/null || echo 0)

  if [ "$ps1_lines" -eq 0 ] || [ "$sh_lines" -eq 0 ]; then
    issues+=("EMPTY_SCRIPT: $base (.ps1=$ps1_lines lines, .sh=$sh_lines lines)")
    continue
  fi

  if [ "$ps1_lines" -gt "$sh_lines" ]; then
    bigger=$ps1_lines
    smaller=$sh_lines
  else
    bigger=$sh_lines
    smaller=$ps1_lines
  fi

  if [ "$bigger" -eq 0 ]; then continue; fi

  pct=$(( (bigger - smaller) * 100 / bigger ))

  if [ "$pct" -gt "$threshold_pct" ]; then
    diverged=$((diverged + 1))
    issues+=("DIVERGED: $base — .ps1=$ps1_lines lines, .sh=$sh_lines lines (${pct}% divergence)")
    echo "  ! $base: .ps1=$ps1_lines lines, .sh=$sh_lines lines (${pct}%)"
  fi
done

# Also check for .sh files missing .ps1 partners
for sh_path in "$scripts_dir"/*.sh; do
  [ -f "$sh_path" ] || continue
  base=$(basename "$sh_path" .sh)
  [[ "$base" == _* ]] && continue
  ps1_path="$scripts_dir/${base}.ps1"
  if [ ! -f "$ps1_path" ]; then
    issues+=("MISSING_PARTNER: $sh_path has no .ps1 counterpart")
  fi
done

echo ""
echo "=== Summary ==="
echo "Pairs checked: $pairs"
echo "Diverged pairs (>${threshold_pct}%): $diverged"
echo "Total issues: ${#issues[@]}"

if [ "${#issues[@]}" -gt 0 ]; then
  echo ""
  echo "=== Issues ==="
  printf ' - %s\n' "${issues[@]}"
  echo ""
  echo "Suggestion: prioritize pairs with the largest divergence for refactoring."
  exit 2
fi

echo ""
echo "pair-consistency-check passed."
