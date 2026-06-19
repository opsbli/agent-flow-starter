# Report

## Delivered

### 1. Emergency 回填过期检测
- `emergency-check.ps1`: 新增 deadline 过期校验 — 如果 backfill deadline 已过但 status 仍为 pending，报错
- `emergency-check.sh`: 新增 deadline 字符串比较校验（兼容 macOS/Linux）

### 2. evolution-stats 跨端一致性
- `evolution-stats.sh`: 修复 AC 计数用 `grep -o` 替代 `grep -c`，消除逐行计数 vs 逐匹配计数的差异（原来会导致 pass rate > 100%）
- `evolution-stats.ps1` + `.sh`: 增加 `ac_pass > ac_total` 的 safety cap

### 3. blocked-check gate fixture 测试
- `scripts/test-gate-fixtures.ps1`: 新增门禁 fixture 测试，验证 blocked-check 能正确识别 hard_delete 违规且不误报 clean change
- `scripts/test-gate-fixtures.sh`: bash 等效
- `agent-flow/test/fixtures/gate-fixtures/blocked-check-scenarios.md`: 测试场景文档

## Verification

- scaffold-health: ✅ pass
- All modified scripts: PowerShell + Bash syntax OK
- gate fixture: blocked-check hard_delete detection ✅ confirmed working
