# Decisions

这里存放 ADR。

先维护索引：

```text
agent-flow/decisions/INDEX.md
```

每新增、废弃或替代 ADR 时，更新索引里的 Status、Supersedes、Superseded By 和 Source Change。

只在同时满足以下条件时创建 ADR：

- 选择难以逆转。
- 存在真实备选方案。
- 未来读者如果没有上下文，会疑惑为什么这么做。

命名：

```text
ADR-0001-use-independent-agent-flow-scaffold.md
```

状态：

```text
Proposed | Accepted | Deprecated | Superseded
```

生命周期：

- `Proposed`：已有明确方案，但尚未被团队接受。
- `Accepted`：当前有效决策。
- `Deprecated`：不再推荐，但没有单一替代 ADR。
- `Superseded`：已被另一个 ADR 明确替代。
