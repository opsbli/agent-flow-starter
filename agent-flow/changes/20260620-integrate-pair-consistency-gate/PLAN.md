# Plan

## 执行阶段

### Phase 1: 元数据更新
- manifest.yaml: pair-consistency-check 从 tools 移至 gates
- gates.txt: 确认已注册

### Phase 2: CI 集成
- scaffold-ci.yml: 新增 `pair-consistency` job
- 使用 `continue-on-error: true` (advisory gate)

### Phase 3: 验证
- scaffold-health + manifest-check + template-check
- 手动运行 CI job 确认输出格式

## 风险缓解

| 风险 | 缓解 |
|------|------|
| 新脚本导致 CI 误报 | continue-on-error + 阈值可调 |
| manifest 分类混乱 | registry-sync 兜底 |
