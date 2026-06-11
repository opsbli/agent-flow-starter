# Code Scan

> **Light 模式**：只需填写「扫描时间」「read_files」「write_files」「未决问题」四个字段。
> **Standard / Heavy 模式**：填写全部字段。

## 扫描时间

YYYY-MM-DD HH:mm

## Machine Check

scan_time: YYYY-MM-DD HH:mm
related_modules: module-or-file
similar_implementations: path-or-none-with-reason
reusable_abstractions: abstraction-or-none-with-reason
test_baseline: command-or-test-file
read_files: path/to/read
write_files: path/to/write
open_questions: none-or-question

> `scan-check -Strict` / `scan-check.sh --strict` 会检查 `read_files` 是否存在，并检查 `write_files` 的目标或父目录是否可落地。

## 相关模块

- 模块：
- 入口：

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| 示例能力 | `path/to/file` | 可复用的模式、接口或约束 |

## 可复用抽象

- 抽象：
- 复用方式：

## 禁止重复实现

- 不重复实现：
- 原因：

## Maven / 模块影响

## 数据库扫描

## 权限扫描

## API / 路由扫描

## 前端扫描

## 测试基线

- 现有测试：
- 可复用命令：

## read_files

read_files:
  - path/to/read

## write_files

write_files:
  - path/to/write

## 破坏性变更

## 未决问题

- 无 / 待确认：
