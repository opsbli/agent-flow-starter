# Tasks

## 执行原则

- 每个任务 5-30 分钟内可完成。
- 每个任务必须有 `Status`，只能使用 `pending`、`in_progress`、`completed`、`blocked`、`skipped`。
- 每个任务必须声明 `read_files` 和 `write_files`。
- 未在 `write_files` 中声明的文件不得修改。
- 每个任务必须有验证命令或验证说明。
- 标记为 `completed` 的任务必须能在 `VERIFY.md` 中找到对应 Task ID 或 AC 证据。
- 修改前后都可以运行 `task-check`，确保任务描述可被机器检查。

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel |
|---|---|---|---|---|---|---|
| T001 | completed | AC-01 | `agent-flow/scripts/manifest-check.ps1`, `agent-flow/scripts/manifest-check.sh` | `agent-flow/scripts/manifest-check.ps1`, `agent-flow/scripts/manifest-check.sh` | `manifest-check.ps1/.sh` | yes |
| T002 | completed | AC-02, AC-03 | `agent-flow/scripts/ac-check.ps1`, `agent-flow/scripts/ac-check.sh`, `agent-flow/templates/VERIFY.md` | `agent-flow/scripts/ac-check.ps1`, `agent-flow/scripts/ac-check.sh` | `scripts/test-starter.ps1/.sh` | yes |
| T003 | completed | AC-04 | `scripts/test-starter.ps1`, `scripts/test-starter.sh`, `agent-flow/scripts/blocked-check.ps1`, `agent-flow/scripts/blocked-check.sh`, `agent-flow/scripts/task-boundary-check.ps1` | `scripts/test-starter.ps1`, `scripts/test-starter.sh`, `agent-flow/scripts/blocked-check.ps1`, `agent-flow/scripts/blocked-check.sh`, `agent-flow/scripts/task-boundary-check.ps1` | `scripts/test-starter.ps1/.sh`; `check-change.ps1` | no |
| T004 | completed | AC-05 | `agent-flow/templates/DESIGN.md`, `agent-flow/templates/EVOLUTION.md`, `agent-flow/decisions/README.md`, `README.md`, `agent-flow/README.md` | `agent-flow/templates/DESIGN.md`, `agent-flow/templates/EVOLUTION.md`, `agent-flow/knowledge/improvement-tracker.md`, `agent-flow/decisions/README.md`, `agent-flow/decisions/INDEX.md`, `README.md`, `agent-flow/README.md` | file inspection + scaffold-health | yes |
| T005 | completed | AC-06 | `agent-flow/scripts/scaffold-health.ps1`, `agent-flow/scripts/scaffold-health.sh`, `agent-flow/manifest.yaml` | `agent-flow/scripts/scaffold-health.ps1`, `agent-flow/scripts/scaffold-health.sh`, `agent-flow/manifest.yaml`, `agent-flow/test/fixtures/minimal-project` | `scaffold-health.ps1/.sh`; `scripts/test-starter.ps1/.sh` | no |

## write_files 汇总

`task-boundary-check` 会读取下面这个机器可读列表。所有任务允许写入的文件都要汇总到这里。

write_files:
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh
  - agent-flow/scripts/ac-check.ps1
  - agent-flow/scripts/ac-check.sh
  - agent-flow/scripts/scaffold-health.ps1
  - agent-flow/scripts/scaffold-health.sh
  - agent-flow/scripts/blocked-check.ps1
  - agent-flow/scripts/blocked-check.sh
  - agent-flow/scripts/task-boundary-check.ps1
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

## 任务列表

### T001 - Manifest TODO guidance

状态：completed

目标：
分类输出 unresolved TODO，并给出下一步。

AC：
AC-01

read_files：
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh

write_files：
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh

步骤：
- 增加 TODO 分类函数。
- 保持 warning/pass 语义。

验证：
manifest-check.ps1/.sh

可并行：
yes

### T002 - AC Evidence strict check

状态：completed

目标：
让 ac-check 解析 VERIFY.md 的 AC Evidence 表并检查字段。

AC：
AC-02, AC-03

read_files：
  - agent-flow/scripts/ac-check.ps1
  - agent-flow/scripts/ac-check.sh
  - agent-flow/templates/VERIFY.md

write_files：
  - agent-flow/scripts/ac-check.ps1
  - agent-flow/scripts/ac-check.sh

步骤：
- 解析 REQUIREMENT AC。
- 解析 VERIFY AC Evidence 表行。
- 检查 evidence location、result、residual risk。

验证：
scripts/test-starter.ps1/.sh

可并行：
yes

### T003 - Gate negative tests

状态：completed

目标：
补充核心 gate 失败路径自测。

AC：
AC-04

read_files：
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - agent-flow/scripts/blocked-check.ps1
  - agent-flow/scripts/blocked-check.sh
  - agent-flow/scripts/task-boundary-check.ps1

write_files：
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - agent-flow/scripts/blocked-check.ps1
  - agent-flow/scripts/blocked-check.sh
  - agent-flow/scripts/task-boundary-check.ps1

步骤：
- 为 scan/design/alignment/ac/code-drift/blocked/task-boundary 增加负例断言。
- 屏蔽 blocked rule ID 自身，避免维护 manifest/gate 规则时误触发。
- 抑制 Windows git 换行警告对 `check-change.ps1` 聚合执行的干扰。

验证：
scripts/test-starter.ps1/.sh

可并行：
no

### T004 - P1 docs and templates

状态：completed

目标：
补充快速开始、UI 设计区域、EVOLUTION tracker、ADR index。

AC：
AC-05

read_files：
  - agent-flow/templates/DESIGN.md
  - agent-flow/templates/EVOLUTION.md
  - agent-flow/decisions/README.md
  - README.md
  - agent-flow/README.md

write_files：
  - agent-flow/templates/DESIGN.md
  - agent-flow/templates/EVOLUTION.md
  - agent-flow/knowledge/improvement-tracker.md
  - agent-flow/decisions/README.md
  - agent-flow/decisions/INDEX.md
  - README.md
  - agent-flow/README.md

步骤：
- README 增加短路径。
- DESIGN 增加 UI Flow / Component Tree / Demo Evidence。
- EVOLUTION 增加 tracker 更新提示。
- decisions 增加 INDEX 和状态说明。

验证：
file inspection + scaffold-health

可并行：
yes

### T005 - Scaffold distribution and verification

状态：completed

目标：
确保新增文件被安装、自检和 manifest 跟踪。

AC：
AC-06

read_files：
  - agent-flow/scripts/scaffold-health.ps1
  - agent-flow/scripts/scaffold-health.sh
  - agent-flow/manifest.yaml

write_files：
  - agent-flow/scripts/scaffold-health.ps1
  - agent-flow/scripts/scaffold-health.sh
  - agent-flow/manifest.yaml
  - agent-flow/test/fixtures/minimal-project
  - agent-flow/changes/p0-p1-starter-improvements

步骤：
- 将新文件纳入 scaffold-health。
- 如需要，同步 minimal-project fixture。
- 运行双平台自测。

验证：
scaffold-health.ps1/.sh; scripts/test-starter.ps1/.sh

可并行：
no

