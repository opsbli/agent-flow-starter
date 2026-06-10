# ADR-0001: Use Independent agent-flow Scaffold

## Status

Accepted

## Context

AI-assisted projects need a workflow that survives across IDEs, chats, and model sessions. Requirements, design decisions, verification evidence, and reusable knowledge should live in the repository rather than only in conversation.

## Decision

Use `agent-flow/` as an independent project-level scaffold.

It contains:

- workflow entry and routing
- source-of-truth rules
- autonomy and protected-area policy
- change templates
- verification gates
- knowledge and ADR folders
- self-evolution guidance

## Consequences

- Each project can initialize `agent-flow` without adopting a specific IDE.
- Root `AGENTS.md` stays short and points agents to `agent-flow/GO.md`.
- Project-specific facts must be initialized in `manifest.yaml` and `knowledge/`.
- Change history belongs in the target project, not in this starter.
