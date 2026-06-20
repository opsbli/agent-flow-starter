# Code Scan

## 扫描时间

2025-09-01 10:00

## Machine Check

scan_time: 2025-09-01 10:00
related_modules: src/components, src/services, src/types
similar_implementations: src/components/ConfirmModal.tsx (Modal 封装模式)
reusable_abstractions: useMutation (React Query), App.Form (Ant Design), apiClient.post() (axios 封装)
test_baseline: npm test -- --testPathPattern="FeedbackModal"
read_files: src/components/ConfirmModal.tsx, src/services/api.ts, src/types/api.ts
write_files: src/components/FeedbackModal.tsx, src/types/feedback.ts, src/services/feedback.ts

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| Modal 封装 | `src/components/ConfirmModal.tsx:8-45` | `visible`/`onClose`/`onOk` props 模式，`App.useApp()` message |
| API 调用 | `src/services/api.ts:20-35` | `apiClient.post<T>()` 泛型封装，错误拦截器 |
| 类型定义 | `src/types/api.ts:5-18` | `ApiResponse<T>` 泛型响应类型 |

## read_files

read_files:
  - src/components/ConfirmModal.tsx
  - src/services/api.ts
  - src/types/api.ts

## write_files

write_files:
  - src/components/FeedbackModal.tsx
  - src/types/feedback.ts
  - src/services/feedback.ts
