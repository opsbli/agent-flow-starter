# Requirement

## 背景
当前 starter 已具备完整目录、模板、脚本和双平台自测。下一步需要让高频失败更早暴露，并让流程演进建议有可追踪出口。

## 用户角色
- Starter 维护者：升级通用 agent-flow 流程。
- 目标项目使用者：安装/初始化 agent-flow 后按提示补齐项目上下文。
- AI 协作者：通过 gate 输出和模板字段判断下一步。

## 术语

| 术语 | 定义 | 是否已沉淀到 glossary |
|---|---|---|
| AC Evidence | `VERIFY.md` 中逐条验收标准的证据表 | no |
| Improvement Tracker | 跟踪 `EVOLUTION.md` 建议是否已进入 starter/项目规则的文件 | no |
| ADR Index | 汇总 ADR 编号、状态和替代关系的索引 | no |

## 目标
- 强化 P0/P1 改进，不增加 Medium 流程或企业化审批。
- 保持 ps1/sh 对等。
- 保持 starter 通用，不写入真实业务项目历史。

## 非目标
- 不新增业务领域规则。
- 不改变 Light/Standard/Heavy 分级。
- 不把聊天报告全文写入 starter。

## 业务规则

| 编号 | 规则 |
|---|---|
| R-01 | manifest TODO 提示必须能告诉使用者下一步填哪里。 |
| R-02 | `ac-check` 必须基于 `VERIFY.md` 的 AC Evidence 表判断每个 AC 是否有证据。 |
| R-03 | 核心 gate 必须至少有成功路径和关键失败路径自测。 |
| R-04 | EVOLUTION 建议必须能进入一个长期跟踪文件或明确不跟踪。 |
| R-05 | ADR 必须能通过索引看到状态和关系。 |
| R-06 | README 入口必须给新用户一条短路径。 |
| R-07 | 前端/交互类设计必须有显式记录区域，但后端/无前端改动可写 none。 |

## 验收标准

编号规则：

- 必须使用 `AC-01`、`AC-02` 这种两位数字编号。
- 不使用 `AC-1`，否则 `agent-flow/scripts/ac-check.ps1` 无法识别。
- 后续 `TASKS.md`、`VERIFY.md`、`REPORT.md` 必须引用同一 AC 编号。

| AC | Given | When | Then | 验证方式 |
|---|---|---|---|---|
| AC-01 | manifest 仍有 TODO | 运行 `manifest-check.ps1/.sh` | 输出 TODO 分类和 next steps，且仍保持 warning/pass 语义 | 自测 + 手工命令 |
| AC-02 | REQUIREMENT 有 AC，VERIFY 缺 AC Evidence 行或字段为空 | 运行 `ac-check.ps1/.sh` | gate 失败并指出缺失 AC/字段 | 负例自测 |
| AC-03 | VERIFY 的 AC Evidence 表完整 | 运行 `ac-check.ps1/.sh` | gate 通过 | 正例自测 |
| AC-04 | starter 自测运行 | 执行 `scripts/test-starter.ps1/.sh` | 覆盖 scan/design/alignment/ac/code-drift/blocked/task-boundary 的关键负例 | 自测输出 |
| AC-05 | 查看流程文档和模板 | 打开 README、DESIGN、EVOLUTION/ADR 文件 | 能看到快速开始、UI 设计区域、改进跟踪和 ADR 索引说明 | 文件检查 |
| AC-06 | 运行 scaffold health | Windows 和 Bash 双平台执行 | 新增/调整文件被纳入健康检查或文档说明，检查通过 | scaffold-health |

## 异常和边界
- 如果目标项目确实没有某类验证命令，TODO 可保留为 none/N/A，但 manifest-check 应提示如何裁决。
- 对 Light change，`ac-check` 仍只有在 REQUIREMENT/VERIFY 同时存在时执行。

## 未决问题
无。

## 用户确认记录
2026-06-11：用户要求“帮我补全 P0 和 P1”。

