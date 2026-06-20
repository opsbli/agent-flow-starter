# Go + Gin + GORM 示例：API 限流中间件

> **流程级别**: Standard  
> **技术栈**: Go 1.22, Gin, GORM, Redis  
> **预计阅读时间**: 12 分钟

## 场景

在一个 Go 后端项目中为 REST API 添加基于 Redis 的令牌桶限流中间件。

## 项目假设

```text
project/
├── internal/
│   ├── middleware/       # 中间件
│   ├── handler/          # HTTP handler
│   ├── service/          # 业务逻辑
│   └── model/            # GORM 模型
├── pkg/
│   └── ratelimit/        # 限流实现
├── config/
│   └── config.yaml
├── go.mod
└── main.go
```

## 工件

| 文件 | 关键内容 |
|------|---------|
| [CHANGE.md](./CHANGE.md) | 变更说明：新增令牌桶限流中间件，Standard 流程 |
| [CODE_SCAN.md](./CODE_SCAN.md) | 扫描现有中间件模式（`internal/middleware/auth.go`），Gin 中间件签名 `gin.HandlerFunc` |
| [DESIGN.md](./DESIGN.md) | 设计决策：令牌桶 vs 固定窗口 vs 滑动窗口；Redis key 命名规范；降级策略 |
