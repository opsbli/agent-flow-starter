# Code Scan

## 扫描时间

2025-08-10 14:00

## Machine Check

scan_time: 2025-08-10 14:00
related_modules: internal/middleware, pkg/, main.go
similar_implementations: internal/middleware/auth.go (JWT 验证中间件)
reusable_abstractions: gin.HandlerFunc 签名, config.Load() 配置加载, Redis client (pkg/redis)
test_baseline: go test ./internal/middleware/...
read_files: internal/middleware/auth.go, main.go, config/config.yaml, pkg/redis/client.go
write_files: pkg/ratelimit/token_bucket.go, internal/middleware/ratelimit.go, main.go, config/config.yaml

## 相关模块

- `internal/middleware/` — 现有中间件目录（auth.go）
- `pkg/redis/` — Redis 客户端封装（go-redis/v9）
- `main.go` — 路由注册入口

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| Gin 中间件模式 | `internal/middleware/auth.go:12-35` | `func AuthMiddleware() gin.HandlerFunc` 签名、`c.AbortWithStatusJSON()` 错误响应 |
| Redis 客户端 | `pkg/redis/client.go:8-22` | `redis.NewClient()` 连接模式、`Ping()` 健康检查 |
| 配置加载 | `config/config.go:15-40` | `viper.Unmarshal()` YAML → struct 映射 |

## 可复用抽象

- `gin.HandlerFunc` — Gin 中间件标准签名
- `pkg/redis.RDB` — 全局 Redis 客户端变量
- `config.AppConfig` — 全局配置 struct

## read_files

read_files:
  - internal/middleware/auth.go
  - main.go
  - config/config.yaml
  - pkg/redis/client.go

## write_files

write_files:
  - pkg/ratelimit/token_bucket.go
  - internal/middleware/ratelimit.go
  - main.go
  - config/config.yaml
