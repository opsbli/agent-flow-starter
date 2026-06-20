# 示例 Changes

> 完整的 agent-flow Change 示例，展示不同流程级别的实际用法。

---

## 示例索引

| 示例 | 流程级别 | 说明 | 预计阅读时间 |
|------|---------|------|------------|
| [sample-change](./sample-change/) | Light | 最小 Change：HTML 页面加一行文本 | 5 分钟 |
| [standard-change](./standard-change/) | Standard | 标准 Change：添加一个 REST API | 15 分钟 |
| [go-gin-rate-limiter](./go-gin-rate-limiter/) | Standard | Go + Gin + Redis：API 限流中间件 | 12 分钟 |
| [react-query-feedback](./react-query-feedback/) | Standard | React + TypeScript + Ant Design：反馈弹窗组件 | 10 分钟 |
| [spring-boot-notification-pref](./spring-boot-notification-pref/) | Heavy | Spring Boot 真实场景：用户通知偏好API | 15 分钟 |
| [heavy-change](./heavy-change/) | Heavy | 重型 Change：新增模块 + 数据库表 | 30 分钟 |

---

## 如何理解这些示例

每个示例目录包含一个完整 Change 的所有工件文件：

```text
change/
├── CHANGE.md              ← 变更说明
├── REQUIREMENT.md         ← 需求（Standard/Heavy）
├── CODE_SCAN.md           ← 代码扫描
├── DESIGN.md              ← 设计文档（Standard/Heavy）
├── PLAN.md                ← 执行计划（Heavy）
├── TASKS.md               ← 任务矩阵
├── VERIFY.md              ← 验证证据
├── REPORT.md              ← 交付报告
├── EVOLUTION.md           ← 复盘沉淀
├── STATE.md               ← 状态跟踪
└── AUDIT.md               ← 审计记录（Heavy）
```

每个文件中的 `TODO` 标记表示需要用户根据项目实际情况填写的内容。

---

## 贡献示例

欢迎贡献你自己的 Change 示例！

### 现有真实技术栈示例

- **[spring-boot-notification-pref](./spring-boot-notification-pref/)** — Java 17 + Spring Boot 3.x + MyBatis-Plus + Sa-Token。展示在真实 Spring Boot 项目中走 Heavy 流程（ALTER TABLE + REST API）的完整过程。

### 要求

1. 包含完整的工件（至少 CHANGE.md + CODE_SCAN.md + VERIFY.md + REPORT.md）
2. 使用的 AC 编号格式为 `AC-01`（两位数字）
3. 所有工件中的 `TODO` 标记需要有说明性文字（但不必须实际填写）
4. 添加 README.md 说明这个示例解决什么问题

### 提交方式

```bash
# 克隆仓库
git clone https://github.com/opsbli/agent-flow-starter.git
cd agent-flow-starter

# 创建新示例
mkdir examples/my-change-example
# ... 添加工件文件 ...

# 提交 PR
git add examples/my-change-example/
git commit -m "docs: add my-change-example demonstrating X"
git push
```

---

## WALKTHROUGH 示例

`examples/heavy-change/` 包含一个完整的 [WALKTHROUGH.md](./heavy-change/WALKTHROUGH.md)，
逐步讲解一个 Heavy Change 从需求到复盘的全部阶段。
