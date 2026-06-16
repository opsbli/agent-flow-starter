# 代码优先上下文

本文件定义类似 Semble 的代码优先检索策略：先查项目事实，再生成方案。

## 扫描顺序

### 1. 项目骨架

优先扫描当前项目真实存在的入口和构建文件，例如：

```text
package.json
pnpm-lock.yaml
pom.xml
build.gradle
settings.gradle
pyproject.toml
requirements.txt
Cargo.toml
go.mod
src/
app/
server/
client/
```

回答：

- 项目使用什么语言、框架、构建工具？
- 模块、包、路由、应用入口在哪里注册？
- 新能力是否需要注册到构建文件、路由、DI 容器、菜单、权限或配置？

### 2. 相似实现

优先找同类实现：

```text
src/**/*
app/**/*
packages/**/*
modules/**/*
services/**/*
components/**/*
tests/**/*
```

必须记录：

- 参考了哪些 Controller / Handler / Service / Repository / Component / Test。
- 哪些写法沿用，哪些不沿用。
- 是否存在命名冲突、职责重叠或重复抽象。

### 3. 公共能力

扫描项目已有公共能力，例如：

```text
common/
shared/
lib/
utils/
core/
infrastructure/
middleware/
hooks/
clients/
```

禁止在业务模块里重复实现公共能力。

### 4. 数据、权限与接口契约

按项目实际情况扫描：

```text
migrations/**
schema/**
sql/**
prisma/**
api/**
routes/**
permissions/**
auth/**
config/**
```

必须记录：

- 新增表、字段、索引、事件、Topic、权限码是否冲突。
- 公开 API、SDK、WebSocket、事件契约是否改变。
- 匿名接口、登录态、Token、租户、数据权限是否受影响。

### 5. 测试

扫描项目测试目录和现有命令：

```text
test/**
tests/**
src/test/**
__tests__/**
*.test.*
*.spec.*
```

必须记录：

- 已有测试风格。
- 本次 AC 如何映射测试或手工验证。
- 哪些只能联调、浏览器、真实数据库或人工验证。

### 6. Standards Snapshot（机器可检查）

扫描结束后，必须在 `CODE_SCAN.md` 记录 `standards_snapshot`，让设计和实现继承已发现的代码约定。

- 如果 `docs/standards/` **不存在**：
  - 从已扫描的代码中提取本次必须遵守的实际约定，写入 `CODE_SCAN.md` 的 `Standards Snapshot`
  - 提取来源：已有模块的命名模式、分层风格、API 路径惯例、DB 命名、权限码格式、测试写法、错误处理方式
  - **只记录代码中实际存在的约定**，不写推测性规则
  - 如果约定会被后续 change 复用，在 `EVOLUTION.md` 里建议新增或更新 `docs/standards/`
- 如果 `docs/standards/` **已存在**：
  - 逐条对照现有标准与代码事实
  - 符合标准 → 在 `standards_snapshot` 记录采用的标准文件
  - 标准缺失或代码事实冲突 → 在 `CODE_SCAN.md` 的「未决问题」中标记，并在 `EVOLUTION.md` 建议是否更新标准

### CODE_SCAN.md 必填结构

```md
# Code Scan

## 相关模块

## 相似实现

## 可复用抽象

## Standards Snapshot

## 禁止重复实现

## 构建 / 模块 / 路由影响

## 数据库 / 权限 / API 扫描

## 测试基线

## read_files

## write_files

## 未决问题
```
