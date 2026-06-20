# Example Freshness Status

> Generated: 2026-06-20
> Gates: content-check, scan-check

## Status Matrix

| Example | Flow | content-check | scan-check | Notes |
|---------|------|---------------|------------|-------|
| heavy-change | Heavy | ✅ 6/6 pass | ⚠️ write_files paths (example) | Complete teaching example |
| standard-change | Standard | ✅ 6/6 pass | ⚠️ write_files paths (example) | Complete teaching example |
| sample-change | Light | ❌ CHANGE.md, CODE_SCAN.md | N/A | Minimal starter — placeholders intentional |
| spring-boot-notification-pref | Standard | ❌ CHANGE.md, CODE_SCAN.md, TASKS.md | N/A | WIP — being drafted |
| go-gin-rate-limiter | — | N/A | N/A | README only |
| react-query-feedback | — | N/A | N/A | CODE_SCAN.md + README only |

## Rules

- **Active examples** (heavy-change, standard-change) must always pass `content-check`.
- **Draft examples** (spring-boot-notification-pref) are allowed placeholder content until finalized.
- **Starter examples** (sample-change) intentionally use placeholders as teaching tool.
