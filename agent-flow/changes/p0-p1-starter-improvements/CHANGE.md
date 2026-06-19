# Change: p0-p1-starter-improvements

## 一句话需求
补全上一轮评审确认的 P0/P1 改进：TODO 收口提示、AC 证据门禁、gate 负例测试、EVOLUTION 闭环、ADR 索引、快速开始和 UI 设计模板。

## 背景
两份架构评测报告指出 starter 下一步应从“骨架完整”走向“执行更准”：现有脚手架健康、自测和 gate 链已可用，但初始化 TODO 提示不够可执行，AC 证据检查偏弱，EVOLUTION 建议缺少跟踪，ADR 缺少索引，README 入口偏长，前端/交互设计记录不够显式。

## 流程级别

- [ ] Light
- [ ] Standard
- [x] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由
Heavy。修改 canonical 脚本、模板、规则、README、测试和 starter 流程文档，影响所有后续安装到目标项目的 agent-flow 使用方式。

## 目标
- P0-01：manifest TODO 输出按人工必填、可自动推断、可保留 none 分类，并给出下一步。
- P0-02：`ac-check` 解析 `VERIFY.md` 的 `AC Evidence` 表，而不是只做全文 AC 编号搜索。
- P0-03：starter 自测补充核心 gate 负例，覆盖失败路径。
- P1-01：增加 EVOLUTION 改进跟踪文件和使用说明。
- P1-02：增加 ADR 索引和状态生命周期说明。
- P1-03：README 增加 3 分钟快速开始。
- P1-04：`DESIGN.md` 增加 UI Flow / Component Tree / Demo Evidence 区域。

## 非目标
- 不新增 Medium 流程级别。
- 不新增企业审批流、视频教程或默认 pre-commit hook。
- 不引入具体业务项目术语、状态、模块名或历史结论。

## 影响范围
- `agent-flow/scripts/*`
- `scripts/test-starter.*`
- `agent-flow/templates/*`
- `agent-flow/knowledge/*`
- `agent-flow/decisions/*`
- `README.md`
- `agent-flow/README.md`
- `agent-flow/GO.md`
- `agent-flow/rules/*`
- `agent-flow/test/fixtures/minimal-project/**`（由自测/同步需要保持模板一致）
- 本 change 工件

## 关联前端

- [x] 否
- [ ] 是：`TODO_FRONTEND_PATH_OR_NONE`

## 风险
- ps1/sh 行为不一致。
- `ac-check` 严格化导致现有示例或自测失败。
- 新增跟踪/索引文件忘记进入 scaffold-health 或 manifest gates。
- 文档变长，削弱 starter 的通用性。

## 需要用户确认的问题
- 无。用户已要求补全 P0/P1；实现中保持通用 starter 边界。

## Emergency（仅 Emergency 流程填写）

- Level: P0 / P1
- Approved by:
- Bypass reason:
- Backfill deadline:
- Backfill status: pending / done / waived

## 工件索引

- State: `agent-flow/changes/p0-p1-starter-improvements/STATE.md`
- Requirement: `agent-flow/changes/p0-p1-starter-improvements/REQUIREMENT.md`
- Code Scan: `agent-flow/changes/p0-p1-starter-improvements/CODE_SCAN.md`
- Design: `agent-flow/changes/p0-p1-starter-improvements/DESIGN.md`
- Tasks: `agent-flow/changes/p0-p1-starter-improvements/TASKS.md`
- Verify: `agent-flow/changes/p0-p1-starter-improvements/VERIFY.md`
- Report: `agent-flow/changes/p0-p1-starter-improvements/REPORT.md`
- Evolution: `agent-flow/changes/p0-p1-starter-improvements/EVOLUTION.md`

