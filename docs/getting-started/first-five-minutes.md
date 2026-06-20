# First Five Minutes

> 从零到完成第一个 Change，5 分钟内搞定。

---

## 你需要什么

- 一个已经安装 `agent-flow` 的项目
- 终端（PowerShell 7+ 或 bash）
- 5 分钟不被打断

还没有安装？先跑：

```bash
# Windows
powershell -c "git clone --depth 1 https://github.com/opsbli/agent-flow-starter.git $env:TMP\af; & $env:TMP\af\scripts\setup-new-pc.ps1 -Target D:\Projects\my-app"

# Linux/macOS
git clone --depth 1 https://github.com/opsbli/agent-flow-starter.git /tmp/af && bash /tmp/af/scripts/setup-new-pc.sh --target /path/to/project
```

---

## 🎯 目标

完成一个 Light Change：在一个现有页面上加一行描述文本。不改数据库、不改权限、不改 API。

---

## Minute 0: 检查脚手架

```bash
# Windows
agent-flow\scripts\scaffold-health.ps1

# Linux/macOS
bash agent-flow/scripts/scaffold-health.sh
```

预期输出：

```
✓ agent-flow/scripts  present
✓ agent-flow/templates  present  
✓ agent-flow/core  present
✓ agent-flow/knowledge  present
✓ agent-flow/flows  present
✓ agent-flow/decisions  present
✓ agent-flow/rules  present
✓ agent-flow/manifest.yaml  present
✓ agent-flow/.gitkeep  present
✓ In-project agent-flow directory is healthy
```

> ⚠️ 如果有 ❌，说明安装不完整。重新运行安装脚本。

---

## Minute 1: 创建你的第一个 Change

```bash
# Windows
agent-flow\scripts\new-change.ps1 -Name my-first-change -Flow Light

# Linux/macOS  
bash agent-flow/scripts/new-change.sh -Name my-first-change -Flow Light
```

你会在 `agent-flow/changes/my-first-change/` 下看到这些文件：

```
CHANGE.md    — 变更说明
CODE_SCAN.md — 代码扫描结果
STATE.md     — 当前状态
```

---

## Minute 2: 看看下一步做什么

```bash
# Windows
agent-flow\scripts\next-step.ps1 -ChangeDir agent-flow\changes\my-first-change

# Linux/macOS
bash agent-flow/scripts/next-step.sh -ChangeDir agent-flow/changes/my-first-change
```

输出会告诉你当前阶段（Stage）和下一步行动。Light 流程的典型顺序是：

```
CHANGE → CODE_SCAN → 实现 → VERIFY → REPORT
```

---

## Minute 3: 完成 CHANGE.md

打开 `agent-flow/changes/my-first-change/CHANGE.md`，填写关键信息：

```markdown
## One-line Requirement

在用户设置页的「个人信息」区块下方增加一行「最后登录时间」文本。

## Flow Level

- [x] Light
- [ ] Standard
- [ ] Heavy  
- [ ] Emergency

## Goal

- 在 user/profile.html 的 .personal-info 区块后插入一行显示文本
- 只改前端模板，不改后端逻辑

## Non-goals

- 不改数据库 schema
- 不改 API
- 不改权限

## Impact

- frontend: user/profile.html
```

---

## Minute 3.5: 运行门禁检查

```bash
# Windows
agent-flow\scripts\check-change.ps1 -ChangeDir agent-flow\changes\my-first-change

# Linux/macOS
bash agent-flow/scripts/check-change.sh -ChangeDir agent-flow/changes/my-first-change
```

Light 流程下只需要通过 `scan-check`（扫描检查）和 `state-check`（状态检查）。

✅ 通过后，就可以去改代码了。

---

## Minute 4: 验证并完成

修改完代码后，更新 `VERIFY.md`，记录验证证据：

```markdown
## Command Log

| 命令 | 结果 |
|------|------|
| git diff | 只改了 user/profile.html |
| code-drift-check | pass |
| task-boundary-check | pass |

## AC Evidence

| AC | 验证方式 | 结果 |
|----|---------|------|
| AC-01: 页面显示最后登录时间 | 打开页面确认文本存在 | ✅ |
```

然后跑：

```bash
# Windows
agent-flow\scripts\closure-check.ps1 -ChangeDir agent-flow\changes\my-first-change

# Linux/macOS
bash agent-flow/scripts/closure-check.sh -ChangeDir agent-flow/changes/my-first-change
```

---

## 🎉 完成了！

你刚刚完成了你的第一个 agent-flow Change。总共不到 5 分钟。

### 接下来学什么

| 阶段 | 内容 | 预计时间 |
|------|------|---------|
| **Phase 1** | Standard 流程（含 Requirements Grill + DESIGN） | 30 分钟 |
| **Phase 2** | Heavy 流程（含 Plan Audit + Closure Audit） | 1 小时 |
| **Phase 3** | Emergency 通道 / 自定义 Gate | 30 分钟 |
| **进阶** | 写自己的 EVOLUTION.md → 改善流程本身 | 按需 |

完整渐进式学习路径：`docs/learning-path.md`

### 常用命令速查

| 场景 | 命令 |
|------|------|
| 创建 Change | `new-change.ps1 -Name <id> -Flow <Light/Standard/Heavy>` |
| 看下一步 | `next-step.ps1 -ChangeDir <dir>` |
| 跑所有门禁 | `check-change.ps1 -ChangeDir <dir>` |
| 查看进度 | `dashboard.ps1` |
| 脚手架健康 | `scaffold-health.ps1` |
| 快速开始 | `af-quickstart.ps1` |
