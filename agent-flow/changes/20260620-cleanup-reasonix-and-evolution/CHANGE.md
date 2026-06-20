# Change: cleanup-reasonix-and-evolution

## 一句话需求

清理 `.reasonix/` 中不应追踪的自动生成文件，补填 `changes/20260620-integrate-pair-consistency-gate/EVOLUTION.md`。

## 背景

1. `.reasonix/desktop-topic-*.json` 是 AI IDE (Reasonix) 自动生成的会话元数据缓存文件，不应留在版本控制中。目录已在 `.gitignore` 中，但已有文件需要删除。
2. `changes/20260620-integrate-pair-consistency-gate/EVOLUTION.md` 仍包含模板占位内容（`none-or-summary`），从未被真正填写。

## 流程级别

- [x] Light
- [ ] Standard
- [ ] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

清理 + 补填，单文件、无逻辑变更。

## 影响范围

- `.reasonix/desktop-topic-created-at.json`（删除）
- `.reasonix/desktop-topic-title-sources.json`（删除）
- `.reasonix/desktop-topic-titles.json`（删除）
- `agent-flow/changes/20260620-integrate-pair-consistency-gate/EVOLUTION.md`（补填）

## 风险

- **无**
