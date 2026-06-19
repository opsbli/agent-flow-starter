# Report

## Delivered

- **TASKS.md 模板**: 新增 `conflict_warning` 列，任务写同一文件时可标记 `overlaps-with-T###` 阻止并行执行
- **manifest.yaml**: 新增 `integration_test` 和 `api_test` 命令字段，项目可声明集成测试和 API 契约测试入口

## Verification

- template-check: ✅ pass
- scaffold-health: ✅ pass

## Rollback

1. Revert TASKS.md template — remove conflict_warning column and documentation
2. Revert manifest.yaml — remove integration_test and api_test lines
