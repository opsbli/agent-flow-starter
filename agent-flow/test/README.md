# agent-flow 测试

本目录包含 agent-flow 脚手架的自检测试。

## 测试策略

| 类型 | 位置 | 执行 |
|---|---|---|
| 脚手架完整性 | `scaffold-health-*` | `scaffold-health.ps1/.sh` |
| 脚本参数测试 | `test-scripts/` | 手动或 CI |
| Starter 端到端自测 | 根级 `scripts/test-starter.ps1/.sh` | 模拟新项目 → 初始化 → gate 正反例 → closure |
| 跨平台一致性 | `.github/workflows/scaffold-ci.yml` | 检查 ps1/sh 配对、语法和双平台自测 |

## 运行测试

Windows PowerShell:

```powershell
# 脚手架健康检查
agent-flow/scripts/scaffold-health.ps1

# 脚本冒烟测试
powershell -NoProfile -File agent-flow/test/test-scripts/test-new-change.ps1
```

Linux/macOS:

```bash
# 脚手架健康检查
bash agent-flow/scripts/scaffold-health.sh

# 脚本冒烟测试
bash agent-flow/test/test-scripts/test-new-change.sh
```

## 测试 Fixtures

`agent-flow/test/fixtures/minimal-project/` 是一个最小项目骨架，
用于模拟新项目初始化和 change 流程。

`agent-flow/test/fixtures/next-step-tests/` 是静态样例数据。测试脚本应复制或生成临时 fixture，不应改写这里的已跟踪文件。

## 添加新测试

1. 在 `test-scripts/` 下创建 `.ps1` 和对应的 `.sh`。
2. 两个脚本必须测试相同的断言集合。
3. 测试失败时 exit 1，通过时 exit 0。
