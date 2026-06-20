# Change: API 限流中间件

## 一句话需求

新增基于 Redis 令牌桶的 API 限流中间件，对所有 `/api/*` 路由启用每秒 100 请求的默认限制。

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy
- [ ] Emergency

## 分级理由

单模块功能（新增中间件），不改 schema/auth。但涉及 Redis 依赖和全局路由影响，需 CODE_SCAN + Design Alignment。

## 目标

- 新增 `pkg/ratelimit/token_bucket.go` — 令牌桶实现
- 新增 `internal/middleware/ratelimit.go` — Gin 中间件
- `main.go` 注册中间件到 `/api/*` 路由组
- Redis 降级：Redis 不可用时放行所有请求

## 非目标

- 不支持按用户/API key 区分的限流
- 不限流 `/health` 和 `/metrics` 端点

## 影响范围

- `pkg/ratelimit/token_bucket.go` — 新建
- `internal/middleware/ratelimit.go` — 新建
- `main.go` — 新增中间件注册
- `config/config.yaml` — 新增限流配置段
