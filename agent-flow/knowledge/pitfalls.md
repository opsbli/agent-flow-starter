# Pitfalls

| Pitfall | Consequence | Guardrail | Source Change |
|---|---|---|---|
| Creating abstractions before scanning existing code | Duplicated behavior and project-style drift | `CODE_SCAN.md` must list similar implementations first | starter |
| Changing public contracts without an explicit decision | Frontend/backend or external clients break silently | `DESIGN.md` must include API / Permission / Auth decisions | starter |
| Completing work without AC evidence | The change looks done but cannot be audited | `VERIFY.md` must include an AC Evidence table | starter |
| Treating chat as durable memory | Future agents lose decisions or repeat mistakes | Move reusable knowledge into `agent-flow/knowledge` or ADRs | starter |
