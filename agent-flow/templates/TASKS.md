# Tasks

## 执行原则

- 每个任务 5-30 分钟内可完成。
- 每个任务必须有 `Status`，只能使用 `pending`、`in_progress`、`completed`、`blocked`、`skipped`。
- 每个任务必须声明 `read_files` 和 `write_files`。
- 未在 `write_files` 中声明的文件不得修改。
- 每个任务必须有验证命令或验证说明。
- 修改前后都可以运行 `task-check`，确保任务描述可被机器检查。

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel |
|---|---|---|---|---|---|---|
| T001 | pending | AC-01 | `path/to/read` | `path/to/write` | `command or manual check` | no |

## write_files 汇总

`task-boundary-check` 会读取下面这个机器可读列表。所有任务允许写入的文件都要汇总到这里。

write_files:
  - path/to/write

## 任务列表

### T001 - {name}

状态：pending

目标：

AC：

read_files：
  - path/to/read

write_files：
  - path/to/write

步骤：

验证：

可并行：

### T002 - {name}

状态：pending

目标：

AC：

read_files：
  - path/to/read

write_files：
  - path/to/write

步骤：

验证：

可并行：
