# 记忆沉淀

聊天不是记忆，文件才是记忆。

## 知识类型

| 类型 | 位置 | 何时写入 |
|---|---|---|
| 领域术语 | `agent-flow/knowledge/glossary.md` | 新概念、旧概念改名、术语歧义被解决 |
| 模块地图 | `agent-flow/knowledge/module-map.md` | 新模块、新依赖、新边界 |
| 既有抽象 | `agent-flow/knowledge/reuse-map.md` | 发现可复用 Service、工具、注解、组件 |
| 坑点 | `agent-flow/knowledge/pitfalls.md` | AI 差点误改、重复实现、权限/SQL/缓存踩坑 |
| 验证经验 | `agent-flow/knowledge/verification.md` | 新增验证命令、测试方式、联调步骤 |
| 前端语汇 | `agent-flow/knowledge/frontend-fit.md` | 新 UI 风格、组件库约束、视觉规则 |

## 决策类型

写 ADR 的门槛：

- 难以逆转。
- 有真实替代方案。
- 未来读者会问“为什么这么做”。

位置：

```text
agent-flow/decisions/ADR-0001-title.md
```

## 每次交流后的沉淀规则

当用户确认一个重要事实，立即写入对应文件，不等到最后。

示例：

- “这个模块必须独立部署” -> `module-map.md` 或 ADR。
- “匿名接口不能复用后台 Controller” -> `pitfalls.md` 或 `glossary.md`。
- “库存状态只有这 4 个” -> `glossary.md`。
- “这次先不做 WebSocket” -> `CHANGE.md` 的 Non-goals。

## 不沉淀什么

- 临时猜测。
- 未确认的实现细节。
- 一次性命令输出。
- 可以从代码直接读出的普通事实。
