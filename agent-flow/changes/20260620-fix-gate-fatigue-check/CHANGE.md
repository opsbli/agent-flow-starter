# Change: fix-gate-fatigue-check

## 一句话需求

修复 `gate-fatigue-check.sh` 运行时因 `set -euo pipefail` 下关联数组声明方式导致 `GATE_TOTAL: unbound variable` 崩溃的 bug。

## 背景

`agent-flow/scripts/gate-fatigue-check.sh` 第 30 行使用 `declare -A GATE_TOTAL GATE_PASS GATE_FAIL GATE_CONSEC GATE_LAST` 批量声明关联数组。但 bash 的 `declare -A` 仅对紧接的第一个变量生效，其余实际未正确初始化。当无 `CHECK_RESULT.json` 文件存在时（无历史数据），数组无键被赋值，`set -u` 将其视为 unbound，导致 `${#GATE_TOTAL[@]}` 触发运行时错误。

## 流程级别

- [x] Light
- [ ] Standard
- [ ] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

单文件 bugfix，不涉及模板/流程变更。

## 影响范围

- `agent-flow/scripts/gate-fatigue-check.sh`

## 风险

- **低**：仅修复声明语法，不影响运行时行为

## 工件索引

- State: STATE.md
- Change: CHANGE.md
- Code Scan: CODE_SCAN.md
- Verify: VERIFY.md
- Report: REPORT.md
