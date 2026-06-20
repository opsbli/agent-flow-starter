# React + TypeScript 示例：用户反馈弹窗

> **流程级别**: Standard（前后端协作）  
> **技术栈**: React 18, TypeScript, Ant Design 5, React Query  
> **预计阅读时间**: 10 分钟

## 场景

在 React 管理后台中新增用户反馈弹窗组件，调用后端 `POST /api/feedback` 接口。

## 项目假设

```text
frontend/
├── src/
│   ├── components/     # 通用组件
│   ├── pages/          # 页面
│   ├── services/       # API 调用 (axios)
│   ├── hooks/          # 自定义 hooks
│   └── types/          # TypeScript 类型
├── package.json
└── tsconfig.json
```

## 工件

| 文件 | 关键内容 |
|------|---------|
| [CHANGE.md](./CHANGE.md) | 新增 FeedbackModal 组件，Light→Standard 升级（涉及用户可见交互） |
| [CODE_SCAN.md](./CODE_SCAN.md) | 扫描现有 Modal 模式（`components/ConfirmModal`）、API 调用模式（`services/api.ts`）、类型定义（`types/api.ts`） |
| [DESIGN.md](./DESIGN.md) | 设计决策：受控 vs 非受控组件、乐观更新 vs 等待响应、Ant Design Form 集成 |

## 关键决策

| # | 决策 | 选择 | 理由 |
|---|------|------|------|
| D-01 | 组件模式 | 受控组件（visible/onClose） | 与项目现有 Modal 模式一致 |
| D-02 | API 调用 | React Query `useMutation` | 自动处理 loading/error/success 状态 |
| D-03 | 表单库 | Ant Design `Form` | 项目已使用 Ant Design，无需引入新依赖 |
