# AI Autonomy Policy

## Purpose

Define what AI may do without explicit human approval in the current project.

## Levels

| Level | Meaning |
|---|---|
| `research-only` | AI may read, scan, and write analysis docs only |
| `plan-first` | AI may research and draft change docs; implementation waits for approval |
| `implement-safe` | AI may implement low-risk changes inside declared `write_files` |
| `implement-with-gates` | AI may implement non-trivial changes after plan audit and must pass gates |
| `ask-first` | AI must ask before any non-trivial action |
| `blocked` | AI must stop |

## Current Default

Default autonomy: `plan-first`.

Upgrade per change only when:

- `CODE_SCAN.md` is complete.
- `DESIGN.md` is reviewed or clearly bounded.
- `TASKS.md` lists `read_files` and `write_files`.
- Protected areas are not touched, or approval is recorded.

## Protected Areas

Human approval is required before modifying:

- database schema, seed data, migrations, SQL/schema files
- auth, permission, Sa-Token config, security filters, permission annotations
- public REST API paths, methods, request/response contracts
- Redis token/session semantics
- WebSocket protocol semantics
- deployment, Docker, Jenkinsfile, production config
- license, billing, payment, entitlement logic
- hard delete, batch delete, destructive data operations
- root build files, workspace files, module registration, or application entry dependencies

## Design Decision Rule

**Every design decision in DESIGN.md must reference a specific code location.** This prevents AI from writing plausible-sounding but code-unfounded designs.

Required format:
```
决策: 使用 [方案名]
引用: src/main/java/.../SomeClass.java:42 — see getWithLock() pattern
理由: [基于代码事实的解释]
```

`content-check` 门禁会验证：
- DESIGN.md 必须有 ≥3 个代码引用
- 每个引用必须是 `path/to/File.ext:line` 格式或 `path/to/File.ext` 格式
- 纯逻辑推理的决策（"使用 Redis 因为快"）会被标记为证据不足

## Allowed Without Approval

- read/search/analyze code
- create or update `agent-flow/changes/**` docs
- update `agent-flow/knowledge/**`
- draft ADRs as Proposed
- run verification scripts
- implement Light changes within declared `write_files`

## Stop Conditions

Stop and ask if:

- protected areas are required
- scope expands beyond `TASKS.md`
- tests reveal behavior not covered by Requirement
- code contradicts accepted ADR or knowledge
- implementation requires deleting more than 5 lines outside generated or local task files
