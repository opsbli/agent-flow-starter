#!/usr/bin/env bash
# Scan public docs and scripts for mojibake and broken fenced code blocks.

set -euo pipefail

project_root="."
while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-root|-ProjectRoot) project_root="$2"; shift 2 ;;
    -h|--help) echo "Usage: doc-quality-check.sh [--project-root .]"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

project_root="$(cd "$project_root" && pwd)"

python3 - "$project_root" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
patterns = [chr(cp) for cp in (0x9225, 0x9241, 0x923F, 0x9983, 0xFFFD, 0x93C3, 0x93C8, 0x6D93, 0x9350, 0x7F02, 0x5A34, 0x9428)]
suffixes = {".md", ".ps1", ".sh", ".yml", ".yaml"}
skip_parts = {
    ".git",
    "fixtures",
}
skip_roots = {
    pathlib.PurePath("agent-flow/changes"),
    pathlib.PurePath("agent-flow/logs"),
    pathlib.PurePath("agent-flow/reports"),
}
issues = []

def under_skip_root(rel: pathlib.Path) -> bool:
    rel_posix = rel.as_posix()
    return any(rel_posix == str(p) or rel_posix.startswith(str(p) + "/") for p in skip_roots)

for path in root.rglob("*"):
    if not path.is_file() or path.suffix not in suffixes:
        continue
    rel = path.relative_to(root)
    if any(part in skip_parts for part in rel.parts) or under_skip_root(rel):
        continue
    text = path.read_text(encoding="utf-8", errors="replace")
    if any(p in text for p in patterns):
        issues.append(f"Potential mojibake in {rel.as_posix()}")
    if path.suffix == ".md" and sum(1 for line in text.splitlines() if line.startswith("```")) % 2:
        issues.append(f"Unbalanced markdown fences in {rel.as_posix()}")

if issues:
    print("Doc quality check failed:")
    for issue in issues:
        print(f" - {issue}")
    sys.exit(2)
print("Doc quality check passed.")
PY
