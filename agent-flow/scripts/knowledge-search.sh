#!/usr/bin/env bash
set -euo pipefail

query=""
knowledge_root="agent-flow/knowledge"
decision_root="agent-flow/decisions"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --query|-Query)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      query="$2"; shift 2 ;;
    --knowledge-root|-KnowledgeRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      knowledge_root="$2"; shift 2 ;;
    --decision-root|-DecisionRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      decision_root="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: knowledge-search.sh --query <text> [--knowledge-root agent-flow/knowledge] [--decision-root agent-flow/decisions]"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$query" ]; then
  echo "Missing required argument: --query" >&2
  exit 2
fi

roots=()
[ -d "$knowledge_root" ] && roots+=("$knowledge_root")
[ -d "$decision_root" ] && roots+=("$decision_root")
if [ "${#roots[@]}" -eq 0 ]; then
  echo "Knowledge search failed:" >&2
  echo " - No searchable roots found." >&2
  exit 2
fi

set +e
grep -RIn --include='*.md' -F -- "$query" "${roots[@]}"
code=$?
set -e

if [ "$code" -eq 1 ]; then
  echo "No knowledge matches for: $query"
  exit 1
fi
exit "$code"
