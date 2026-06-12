# Decisions

这里存放 ADR。

先维护索引：

```text
agent-flow/decisions/INDEX.md
```

每新增、废弃或替代 ADR 时，更新索引里的 Status、Supersedes、Superseded By 和 Source Change。
ADR 文件记录完整理由，`INDEX.md` 记录生命周期状态；两者不一致时，以 ADR 文件为事实源并立即修正索引。

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

生命周期变更规则：

- `Proposed -> Accepted`：需要记录接受来源或对应 change。
- `Accepted -> Deprecated`：必须说明为什么不再推荐。
- `Accepted -> Superseded`：必须填写 `Superseded By`。
- 新 ADR 替代旧 ADR 时，新 ADR 填 `Supersedes`，旧 ADR 填 `Superseded By`。
