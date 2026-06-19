# Evolution

problem: Gate scripts failed on valid starter inputs because parser assumptions were too brittle.
knowledge: Manifest list values may have inline comments; real paths may include `examples/`; core cross-platform scripts should prefer ASCII status labels.
adr: none
gate: Existing syntax checks and starter self-tests cover the repaired failure modes after this patch.
template: none
no_change_reason: Flow routing and template structure were not the cause; script reliability was the right repair layer.

## 本次发现

- Gate chains need direct runnable sample coverage; syntax-only checks are not enough.
- Placeholder detection should not reject real paths such as `examples/...`.
- Non-ASCII status glyphs can become corrupted across PowerShell, Git, and WSL paths; core scripts are safer with ASCII status labels.

## 应升级的规则

- Keep aggregate gate scripts covered by at least one runnable sample change.
- When generated change ids may include date or project prefixes, tests should assert by suffix or parse script output instead of hard-coding the full id.

## 应新增的知识

- `manifest-check` and `blocked-check` must allow inline comments after YAML list values.
- `run-verify` should strip wrapping quotes only when the entire value is quoted.

## 应新增的验证闸门

- Existing syntax checks and starter self-tests are enough after this patch because they now cover the failure cases.

## 应调整的模板

- No template changes needed.

## 应更新的标准

- Prefer ASCII status labels in core cross-platform scripts.

## 本次不调整的原因

- Flow routing and Heavy gate policy were not the cause of the failure; script reliability was.
