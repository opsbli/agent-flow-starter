# agent-flow-starter Agent 规则

> 本仓库是 `agent-flow` AI 开发流程的通用 starter。
> 保持通用，不要写入具体业务项目的历史、需求或领域规则。

## 默认入口

在本 starter 仓库内工作时，先读：

```text
agent-flow/README.md
```

修改流程本身时，还必须读：

```text
agent-flow/GO.md
agent-flow/manifest.yaml
agent-flow/core/source-of-truth.md
agent-flow/core/evolution.md
```

## 编辑规则

- `AGENTS.md` 只保留短规则和硬约束。
- 详细用法写入 `README.md` 或 `agent-flow/README.md`。
- 模板必须保持通用，不写具体项目名称、模块名、业务状态或历史结论。
- 不要把真实项目的 `changes/`、`logs/`、`reports/`、`known-good-baselines/` 放进 starter。
- 修改脚本时，凡是适用的能力必须同时更新 Windows `.ps1` 和 Linux/macOS `.sh`。
- 修改脚手架结构后，必须运行两套 `scaffold-health`。

## 安装契约

starter 必须支持：

- 在目标项目创建或更新 `agent-flow/`。
- 在目标项目创建或更新 `AGENTS.md` 中的 `agent-flow` 区块。
- 除非显式强制覆盖，否则保留目标项目的 `agent-flow/changes`、`agent-flow/logs`、`agent-flow/reports`。
