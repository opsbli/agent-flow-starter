# agent-flow 流程架构图

> 可视化 agent-flow 的核心流程、路由判定和门禁时序。

---

## 1. 路由判定树

```mermaid
flowchart TD
    A[需求进入] --> B{P0/P1 事故?}
    B -->|YES| C[Emergency 通道<br/>绕过标准门禁<br/>24h 回填]
    B -->|NO| D[建立 Change 工件]
    D --> E[Code-First 代码扫描]
    E --> F{路由分级}
    F --> G[Light]
    F --> H[Standard]
    F --> I[Heavy]

    G --> G1[CHANGE.md]
    G1 --> G2[CODE_SCAN.md]
    G2 --> G3[TDD 实现]
    G3 --> G4[VERIFY.md]
    G4 --> G5[REPORT.md]

    H --> H1[CHANGE.md + REQUIREMENT.md]
    H1 --> H2[Requirements Grill]
    H2 --> H3[CODE_SCAN.md]
    H3 --> H4[DESIGN.md]
    H4 --> H5{Design Alignment}
    H5 -->|aligned| H6[TASKS.md]
    H5 -->|blocked| H4
    H6 --> H7[TDD 实现]
    H7 --> H8[VERIFY.md + REPORT.md]
    H8 --> H9[EVOLUTION.md]

    I --> I1[CHANGE.md + STATE.md]
    I1 --> I2[Requirements Grill]
    I2 --> I3[CODE_SCAN.md]
    I3 --> I4[DESIGN.md]
    I4 --> I5{Design Alignment}
    I5 -->|aligned| I6[PLAN.md]
    I5 -->|blocked| I4
    I6 --> I7{Plan Audit}
    I7 -->|accept| I8[TASKS.md]
    I7 -->|conditional| I6
    I7 -->|reject| I6
    I8 --> I9[分阶段 TDD 实现]
    I9 --> I10[VERIFY.md + REVIEW.md]
    I10 --> I11{Closure Audit}
    I11 -->|pass| I12[REPORT.md + EVOLUTION.md]
    I11 -->|conditional| I13[修复 + 回审]
    I13 --> I11
```

---

## 2. Light 流程门禁时序

```mermaid
sequenceDiagram
    participant Dev as 开发者/AI
    participant Change as Change 目录
    participant Gates as 门禁脚本

    Dev->>Change: new-change.ps1 (创建目录)
    Dev->>Change: 写 CHANGE.md
    Dev->>Change: 写 CODE_SCAN.md
    Dev->>Gates: scan-check
    Gates-->>Dev: ✅ 通过
    Dev->>Change: TDD 实现 (RED→GREEN→REFACTOR)
    Dev->>Change: 写 VERIFY.md
    Dev->>Gates: check-change
    Gates-->>Dev: ✅ 所有门禁通过
    Dev->>Change: 写 REPORT.md
    Note over Dev,Change: Done ✅
```

---

## 3. Standard 流程门禁时序

```mermaid
sequenceDiagram
    participant Dev as 开发者/AI
    participant User as 用户
    participant Gates as 门禁脚本
    participant Knowledge as 知识库

    Dev->>Gates: new-change.ps1
    Dev->>User: Requirements Grill (一次一个问题)
    User-->>Dev: 确认/修正
    Dev->>Knowledge: 沉淀术语
    Dev->>Gates: 写 REQUIREMENT.md + CODE_SCAN.md
    Dev->>Gates: scan-check
    Gates-->>Dev: ✅ 通过
    Dev->>Gates: 写 DESIGN.md → design-check
    Gates-->>Dev: ✅ 通过
    Dev->>User: Design Alignment (≥3 个问题)
    User-->>Dev: aligned ✅
    Dev->>Gates: alignment-check
    Gates-->>Dev: ✅ 通过
    Dev->>Gates: 写 TASKS.md → task-check
    Gates-->>Dev: ✅ 通过
    Dev->>Dev: TDD 实现 (每个任务 RED→GREEN→REFACTOR)
    Dev->>Gates: VERIFY.md → check-change
    Gates-->>Dev: ✅ 通过
    Dev->>Gates: REPORT.md + EVOLUTION.md
    Dev->>Gates: evolution-check
    Gates-->>Dev: ✅ 通过
    Note over Dev,Knowledge: 完成 ✅
```

---

## 4. Heavy 流程门禁时序

```mermaid
sequenceDiagram
    participant Dev as 开发者/AI
    participant User as 用户
    participant Gates as 门禁脚本
    participant Logs as 日志/审计

    Dev->>Gates: new-change.ps1 (-Flow Heavy)
    Dev->>User: Requirements Grill
    User-->>Dev: 确认需求
    Dev->>Gates: CODE_SCAN.md → scan-check
    Gates-->>Dev: ✅
    Dev->>Gates: DESIGN.md → design-check
    Gates-->>Dev: ✅
    Dev->>User: Design Alignment (≥3 问题)
    User-->>Dev: aligned
    Dev->>Gates: alignment-check
    Gates-->>Dev: ✅
    Dev->>Gates: PLAN.md
    Dev->>User: Plan Audit
    User-->>Dev: accept ✅
    Dev->>Gates: plan-check
    Gates-->>Dev: ✅
    Dev->>Gates: TASKS.md → task-check
    Gates-->>Dev: ✅
    Dev->>Dev: 阶段 TDD 实现 (Phase 1 → 2 → 3)
    Dev->>Gates: 阶段验证
    Dev->>Gates: VERIFY.md + REVIEW.md
    Dev->>Gates: code-drift-check + blocked-check + task-boundary-check
    Gates-->>Dev: ✅
    Dev->>Gates: closure-check
    Gates-->>Dev: ✅
    Dev->>Logs: 写入 agent-flow/logs/
    Dev->>Gates: REPORT.md + EVOLUTION.md
    Dev->>Gates: evolution-check
    Gates-->>Dev: ✅
    Note over Dev,Logs: 完成 ✅
```

---

## 5. 工件依赖关系

```mermaid
graph LR
    CHANGE[CHANGE.md] --> SCAN[CODE_SCAN.md]
    CHANGE --> REQ[REQUIREMENT.md]
    SCAN --> DESIGN[DESIGN.md]
    REQ --> DESIGN
    DESIGN --> TASKS[TASKS.md]
    DESIGN --> PLAN[PLAN.md]
    PLAN --> AUDIT[AUDIT.md]
    TASKS --> IMPLEMENT[TDD 实现]
    IMPLEMENT --> VERIFY[VERIFY.md]
    VERIFY --> REPORT[REPORT.md]
    REPORT --> EVOLUTION[EVOLUTION.md]
    EVOLUTION --> KNOWLEDGE[agent-flow/knowledge/]
    AUDIT --> VERIFY

    style CHANGE fill:#e1f5fe
    style SCAN fill:#e1f5fe
    style REQ fill:#e1f5fe
    style DESIGN fill:#fff3e0
    style TASKS fill:#fff3e0
    style PLAN fill:#fff3e0
    style AUDIT fill:#fce4ec
    style VERIFY fill:#e8f5e9
    style REPORT fill:#e8f5e9
    style EVOLUTION fill:#f3e5f5
```

---

## 6. 自动迭代循环

```mermaid
flowchart LR
    CHANGE[每次 Change] --> EVOLUTION[EVOLUTION.md]
    EVOLUTION --> SUGGEST[evolution-suggest]
    SUGGEST --> TRACKER[improvement-tracker.md]
    TRACKER --> GATES[门禁升级]
    TRACKER --> TEMPLATES[模板升级]
    TRACKER --> KNOWLEDGE[知识沉淀]
    TRACKER --> SCRIPTS[新脚本]

    DASHBOARD[dashboard] --> FATIGUE[gate-fatigue-check]
    FATIGUE -->|门禁疲劳| GATES

    PATTERN[pattern-discovery] -->|重复模式| KNOWLEDGE

    EXPIRY[knowledge-expiry-check] -->|知识过期| KNOWLEDGE
```

---

*文档生成时间: 2026-06*  
*更新: 每次 EVOLUTION.md 复盘后检查本图是否需要更新*
