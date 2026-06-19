# Code Scan

> **Light 模式**：只需填写「扫描时间」「read_files」「write_files」「未决问题」四个字段。
> **Standard / Heavy 模式**：填写全部字段。

## 扫描时间

2026-06-11 00:00

## Machine Check

scan_time: 2026-06-11 00:00
related_modules: agent-flow/scripts, agent-flow/templates, agent-flow/knowledge, agent-flow/decisions, scripts/test-starter
similar_implementations: agent-flow/scripts/manifest-check.ps1; agent-flow/scripts/ac-check.ps1; agent-flow/scripts/blocked-check.ps1; agent-flow/scripts/task-boundary-check.ps1; scripts/test-starter.ps1
reusable_abstractions: agent-flow/scripts/_common.ps1; agent-flow/scripts/_common.sh; agent-flow/rules/*.keys; existing self-test helper patterns
test_baseline: scripts/test-starter.ps1; scripts/test-starter.sh; agent-flow/scripts/scaffold-health.ps1; agent-flow/scripts/scaffold-health.sh
read_files: agent-flow/GO.md, agent-flow/manifest.yaml, agent-flow/core/source-of-truth.md, agent-flow/core/evolution.md, agent-flow/scripts/manifest-check.ps1, agent-flow/scripts/manifest-check.sh, agent-flow/scripts/ac-check.ps1, agent-flow/scripts/ac-check.sh, agent-flow/scripts/blocked-check.ps1, agent-flow/scripts/blocked-check.sh, agent-flow/scripts/task-boundary-check.ps1, scripts/test-starter.ps1, scripts/test-starter.sh, agent-flow/templates/DESIGN.md, README.md
write_files: agent-flow/scripts/manifest-check.ps1, agent-flow/scripts/manifest-check.sh, agent-flow/scripts/ac-check.ps1, agent-flow/scripts/ac-check.sh, agent-flow/scripts/blocked-check.ps1, agent-flow/scripts/blocked-check.sh, agent-flow/scripts/task-boundary-check.ps1, scripts/test-starter.ps1, scripts/test-starter.sh, agent-flow/templates/DESIGN.md, agent-flow/templates/EVOLUTION.md, agent-flow/knowledge/improvement-tracker.md, agent-flow/decisions/README.md, agent-flow/decisions/INDEX.md, README.md, agent-flow/README.md, agent-flow/scripts/scaffold-health.ps1, agent-flow/scripts/scaffold-health.sh, agent-flow/manifest.yaml, agent-flow/test/fixtures/minimal-project, agent-flow/changes/p0-p1-starter-improvements
open_questions: none

> `scan-check -Strict` / `scan-check.sh --strict` 会检查 `read_files` 是否存在，并检查 `write_files` 的目标或父目录是否可落地。

## 相关模块

- 模块：canonical scripts、templates、knowledge、decisions、starter self-test。
- 入口：`agent-flow/GO.md`、`README.md`、`agent-flow/README.md`。

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| manifest 结构检查 | `agent-flow/scripts/manifest-check.ps1` / `.sh` | 保持 warning/pass 语义，增加 TODO 分类输出 |
| AC 编号检查 | `agent-flow/scripts/ac-check.ps1` / `.sh` | 保留 AC 发现逻辑，改为验证 `VERIFY.md` 表格 |
| blocked 规则检查 | `agent-flow/scripts/blocked-check.ps1` / `.sh` | 复用 manifest blocked_if 解析，屏蔽规则 ID 自身 |
| 任务边界检查 | `agent-flow/scripts/task-boundary-check.ps1` | 保持 git 文件列表逻辑，吸收 Windows git warning |
| 自测临时项目 | `scripts/test-starter.ps1` / `.sh` | 复用 helper 生成临时 change 并断言 gate 正负例 |
| 模板健康检查 | `agent-flow/scripts/scaffold-health.ps1` / `.sh` | 将新知识/索引文件纳入 required 列表 |

## 可复用抽象

- 抽象：`_common.ps1/.sh` 的 meaningful helpers、self-test 的 demo artifact builders、manifest-check 的 issue/warning 输出。
- 复用方式：在现有脚本内扩展函数，不新增独立语言或外部依赖。

## 禁止重复实现

- 不重复实现：不新增 `coverage-check`，先增强 `ac-check`。
- 原因：AC 覆盖属于现有 `VERIFY.md` / `ac-check` 责任。

## Maven / 模块影响
无。

## 数据库扫描
无 schema 修改。

## 权限扫描
无权限/auth 修改。

## API / 路由扫描
无 API/route 修改。

## 前端扫描
无前端代码修改；只补充通用 UI 设计模板区域。

## 测试基线

- 现有测试：`scripts/test-starter.ps1`、`scripts/test-starter.sh`、`agent-flow/test/test-scripts/test-new-change.*`、`test-next-step.*`。
- 可复用命令：`agent-flow/scripts/scaffold-health.ps1`、`bash agent-flow/scripts/scaffold-health.sh`、`scripts/test-starter.ps1`、`bash scripts/test-starter.sh`。

## read_files

read_files:
  - agent-flow/GO.md
  - agent-flow/manifest.yaml
  - agent-flow/core/source-of-truth.md
  - agent-flow/core/evolution.md
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh
  - agent-flow/scripts/ac-check.ps1
  - agent-flow/scripts/ac-check.sh
  - agent-flow/scripts/blocked-check.ps1
  - agent-flow/scripts/blocked-check.sh
  - agent-flow/scripts/task-boundary-check.ps1
  - agent-flow/scripts/scaffold-health.ps1
  - agent-flow/scripts/scaffold-health.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - agent-flow/templates/DESIGN.md
  - agent-flow/templates/EVOLUTION.md
  - agent-flow/decisions/README.md
  - README.md
  - agent-flow/README.md

## write_files

write_files:
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh
  - agent-flow/scripts/ac-check.ps1
  - agent-flow/scripts/ac-check.sh
  - agent-flow/scripts/blocked-check.ps1
  - agent-flow/scripts/blocked-check.sh
  - agent-flow/scripts/task-boundary-check.ps1
  - agent-flow/scripts/scaffold-health.ps1
  - agent-flow/scripts/scaffold-health.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - agent-flow/templates/DESIGN.md
  - agent-flow/templates/EVOLUTION.md
  - agent-flow/knowledge/improvement-tracker.md
  - agent-flow/decisions/README.md
  - agent-flow/decisions/INDEX.md
  - README.md
  - agent-flow/README.md
  - agent-flow/manifest.yaml
  - agent-flow/test/fixtures/minimal-project
  - agent-flow/changes/p0-p1-starter-improvements

## 破坏性变更
无破坏性业务变更。脚本严格化可能改变 gate 失败条件，需通过自测覆盖。

## 未决问题

- 无。

