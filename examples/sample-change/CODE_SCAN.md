# Code Scan

## 扫描时间

2026-06-15 00:00

## Machine Check

scan_time: 2026-06-15 00:00
related_modules: examples/sample-change
similar_implementations: examples/sample-change/VERIFY.md
reusable_abstractions: existing status label example structure
test_baseline: agent-flow/scripts/ac-check.ps1 -ChangeDir examples/sample-change
read_files: examples/sample-change/REQUIREMENT.md, examples/sample-change/DESIGN.md, examples/sample-change/VERIFY.md
write_files: examples/sample-change/CODE_SCAN.md
open_questions: none

## Related Modules

- `src/features/items`
- `src/components/status-label`
- `tests/status-label.test.ts`

## Similar Implementation

Existing labels:

- `active -> Active`
- `disabled -> Disabled`

## Reusable Abstractions

Reuse the existing status label component. Do not create another label renderer.

## read_files

- `src/components/status-label.tsx`
- `tests/status-label.test.ts`

## write_files

- `src/components/status-label.tsx`
- `tests/status-label.test.ts`

## Open Questions

None.
