# 前端适配

如果项目包含前端，前端路径以 `agent-flow/manifest.yaml` 为准。

## 前端代码扫描

新增页面或组件前必须扫描：

- 路由结构。
- API 封装方式。
- 状态管理组织。
- UI 组件库使用习惯。
- 表格、表单、弹窗、按钮、权限指令。
- 颜色、间距、图标、空状态、loading、error。
- 现有页面的信息密度和交互节奏。

## 视觉语汇报告

前端 change 的 `CODE_SCAN.md` 必须增加：

```md
## Visual Vocabulary

- 主色和强调色：
- 常用布局：
- 表格密度：
- 表单标签宽度：
- 按钮类型：
- 图标库：
- hover/focus/loading 规律：
- 文案语气：
- 禁止出现：
```

## 占位符规则

- 缺数据时停下来问，不编造统计数字。
- 缺图标时优先查现有图标库，不用 emoji 顶替。
- 缺图片时使用明确标注的占位块。
- 缺接口时写 mock 边界，不把假数据伪装成真数据。

## 交付前检查

> 如果 `manifest.yaml` 中 `frontend.framework` 不为 `none`，**必须完成以下检查**（执行或记录跳过原因）。
> 如果 `manifest.yaml` 中 `frontend.verify_required` 为 `true`，前端验证检查为 **强制**，联调证据必须出现在 `VERIFY.md` 的 AC Evidence 中。

### 基础检查

- [ ] typecheck (tsc --noEmit)
- [ ] unit/component tests
- [ ] lint/format
- [ ] 浏览器控制台无错误
- [ ] loading / empty / error / disabled 状态齐全
- [ ] 文字不溢出
- [ ] UI 与既有页面视觉上不可区分

### Chrome DevTools 联调检查清单

> 所有涉及前端页面或 API 联调的 change，必须在 Chrome DevTools 中完成以下检查。
> 检查结果记录在 `VERIFY.md` 的 AC Evidence 表中。

#### Network 面板

- [ ] **无 4xx/5xx 错误**：筛选 `status-code: 4xx` 和 `status-code: 5xx`，确认没有非预期的错误响应
- [ ] **请求方法正确**：每个 API 调用的 HTTP Method 与 DESIGN.md 声明一致
- [ ] **请求/响应格式**：确认请求参数和响应体的 JSON 结构与 DESIGN.md 的 API 设计一致
- [ ] **权限拦截验证**：测试未登录或无权限时，接口是否被正确拦截（401/403），不泄露数据
- [ ] **耗时检查**：单个请求 P99 < 项目约定的阈值（如无可不检查）

#### Console 面板

- [ ] **无报错**：Console 无红色 Errors（忽略已知的第三方扩展错误）
- [ ] **无警告**：Console 无项目代码产生的 Warnings（忽略 deprecation 等不影响功能的警告）
- [ ] **无 API 调用异常**：无 `Failed to load resource`、`Uncaught (in promise)` 等异步错误

#### Elements 面板

- [ ] **路由渲染正确**：切换路由后页面组件正确渲染，无空白页
- [ ] **权限元素隐藏**：无权限的元素（按钮、菜单、Tab）正确隐藏或禁用
- [ ] **空状态/loading 状态**：无数据时显示空状态占位，请求中显示 loading 指示

#### Application 面板

- [ ] **Token/登录态**：Local Storage / Session Storage / Cookie 中的认证信息格式正确
- [ ] **无敏感数据泄漏**：Local Storage 中未存储密码、Token 明文（应有 httpOnly Cookie 或加密存储）

### 检查结果记录

在 `VERIFY.md` 的 AC Evidence 表中，**前端相关的 AC** 应记录联调结果：

```
| AC-XX | 前端联调验证 | 手动，Chrome DevTools | Network 无 4xx，Console 无报错 |
```

对于全栈项目（`manifest.yaml` 中 `frontend.repo` 存在），`REPORT.md` 必须包含前端联调结论。
