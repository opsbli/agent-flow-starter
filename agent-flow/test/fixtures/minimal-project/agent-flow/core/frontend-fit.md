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

按项目实际命令执行或记录跳过原因：

- typecheck
- unit/component tests
- lint/format
- 浏览器控制台无错误
- loading / empty / error / disabled 状态齐全
- 文字不溢出
- UI 与既有页面视觉上不可区分
