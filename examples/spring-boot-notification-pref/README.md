# Spring Boot 示例：用户通知偏好 API

> **流程级别**: Standard  
> **技术栈**: Java 17, Spring Boot 3.x, MyBatis-Plus 3.5, MySQL 8.0  
> **预计阅读时间**: 15 分钟

## 这个示例解决什么问题

这是一个真实的 Spring Boot 单体应用场景：在已有的用户管理模块上添加"通知偏好设置"功能。

## 为什么选 Spring Boot

- Spring Boot 是国内最主流的 Java 后端框架
- MyBatis-Plus 是 Spring Boot 生态中使用最广泛的 ORM
- 此示例展示了 agent-flow 在实际 Java 项目中的用法（非虚构 HTML/通用 REST）

## 项目假设

本示例假设目标项目具有以下结构（典型的若依/RuoYi 风格）：

```text
project/
├── src/main/java/com/example/
│   ├── common/          # 公共层（BaseController, R<T>, 全局异常）
│   ├── system/          # 系统模块
│   │   ├── controller/  # SysUserController
│   │   ├── service/     # ISysUserService, SysUserServiceImpl
│   │   ├── mapper/      # SysUserMapper
│   │   └── domain/      # SysUser
│   └── framework/       # 安全框架（Sa-Token）
├── src/main/resources/
│   ├── mapper/system/   # MyBatis XML
│   └── application.yml
└── sql/                 # 数据库迁移脚本
```

## 场景描述

> **场景**：我在一个 Spring Boot 后台管理系统的 `system` 模块做开发。  
> **目标**：需要给用户表新增 `notification_enabled` 字段，提供查询和更新通知偏好的 REST API，不改权限体系。  
> **风险**：涉及数据库 schema 变更（新增字段），不涉及权限变更，不涉及前端。

## 工件文件

| 文件 | 说明 | 关键决策 |
|------|------|---------|
| [CHANGE.md](./CHANGE.md) | 变更说明 + 分级理由 | Schema 变更 → 升级至 Heavy 流程 |
| [REQUIREMENT.md](./REQUIREMENT.md) | 需求定义 | 4 条 AC，含 Given/When/Then |
| [CODE_SCAN.md](./CODE_SCAN.md) | 代码扫描 | 扫描了 SysUser, SysUserService, BaseController，发现可复用模式 |
| [DESIGN.md](./DESIGN.md) | 设计文档 | 设计对齐 5 个必选问题 + 3 个自定义问题 |
| [TASKS.md](./TASKS.md) | 任务矩阵 | T-01 DB迁移, T-02 Entity更新, T-03 Service, T-04 Controller, T-05 验证 |
| [VERIFY.md](./VERIFY.md) | 验证证据 | 5 条 AC 全部 pass，含编译输出和测试结果 |
| [REPORT.md](./REPORT.md) | 交付报告 | 完整 AC 达成矩阵 |
| [EVOLUTION.md](./EVOLUTION.md) | 复盘沉淀 | 发现 SQL 脚本路径约定未文档化，建议更新 standards |
| [STATE.md](./STATE.md) | 状态跟踪 | 自动管理的工作流状态 |

## 关键决策记录

| # | 决策 | 选择 | 理由 |
|---|------|------|------|
| D-01 | 流程级别 | Heavy（从 Standard 升级） | CODE_SCAN 发现需要新增数据库字段 |
| D-02 | 新增列 vs 新建表 | ALTER TABLE 新增列 | 一对一关系，无需独立表 |
| D-03 | 默认值 | `notification_enabled = true` | 用户默认接收通知（opt-out 模式） |
| D-04 | REST 路径 | `GET/PUT /system/user/profile/notification` | 与现有 `/system/user/profile` 保持一致 |
| D-05 | 权限控制 | 复用现有 `system:user:profile` 权限码 | 通知偏好是用户自身设置，复用 profile 权限即可 |

## 如何将此示例适配到你的项目

1. 将 `com.example` 替换为你的项目包名
2. 将权限码 `system:user:profile` 替换为你项目中的实际权限码
3. 根据你的 ORM（MyBatis-Plus / JPA / JdbcTemplate）调整实现方式
4. SQL 脚本路径按你项目的约定调整
