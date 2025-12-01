# Price Memory API 文档

## 概要

后端基于 FastAPI，提供商品与价格监控的 REST 接口。所有接口返回统一响应结构。

- Base URL: `http://localhost:8000/api/v1`
- Content-Type: `application/json`
- 版本: `v1.0.0`

### 响应结构
```json
{
  "success": true,
  "data": {},
  "message": "操作成功",
  "timestamp": "2025-01-01T00:00:00Z"
}
```

错误响应：
```json
{
  "success": false,
  "error": {"code": "NOT_FOUND", "message": "资源不存在", "details": []},
  "timestamp": "2025-01-01T00:00:00Z"
}
```

## 商品接口

- GET `/products`：分页列表
- GET `/products/search`：带筛选和排序的列表（`search`、`category`、`sort_by`、`sort_order`）
- POST `/products`：创建商品
- GET `/products/{product_id}`：商品详情，含统计
- GET `/products/{product_id}/prices`：价格历史（`start_date`、`end_date`）

示例：
```http
GET /api/v1/products/search?page=1&size=20&search=airpods&sort_by=last_updated&sort_order=desc
```

创建商品：
```json
{
  "name": "Apple AirPods Pro",
  "url": "https://www.amazon.com/dp/XXXX",
  "category": "电子产品"
}
```

## 导出接口

- GET `/products/{product_id}/export`：导出单商品价格历史为 CSV（支持 `start_date`、`end_date`、`api_key` 配额校验）
- GET `/export?product_ids=1,2,3`：导出多商品价格历史为 CSV（支持 `start_date`、`end_date`、`api_key` 配额校验）

示例响应头：`Content-Type: text/csv`，`Content-Disposition: attachment; filename="product_1_prices.csv"`

## 爬虫接口

- GET `/spider/tasks`：任务列表（`status`、`product_id`）
- POST `/spider/tasks`：创建任务
- POST `/spider/tasks/{task_id}/execute`：执行任务、入库并更新商品
- POST `/spider/listing`：抓取列表页并解析（请求体：`{ "url": "...", "max_items": 50 }`）

## 用户与关注接口

- POST `/users`：创建用户（自动生成 `api_key`、基础配额）
- GET `/users`：用户列表（支持 `search`）
- GET `/users/{user_id}`：用户详情（含关注数）
- GET `/products/{product_id}/followers`：商品关注者列表
- GET `/users/{user_id}/follows`：用户关注的商品列表
- POST `/users/{user_id}/follows`：关注商品，Body: `{ product_id }`
- DELETE `/users/{user_id}/follows/{product_id}`：取消关注

## 推送分享接口

- POST `/users/{sender_id}/pushes`：向用户推送分享消息，Body: `{ recipient_id, product_id, message? }`
- GET `/users/{user_id}/pushes?box=inbox|outbox`：收件箱或发件箱
- POST `/pushes/{push_id}/status`：更新状态，Body: `{ status: accepted|rejected }`

## 计划中接口

- 公共池与集合协作接口：当前版本未提供，后续将按路线图逐步实现（公共池商品管理、集合成员协作与 Excel 导出）。

## 系统接口

- GET `/system/status`：系统健康状态与今日任务统计

## 错误代码

| 错误代码 | HTTP状态码 | 描述 |
|---|---|---|
| VALIDATION_ERROR | 400 | 请求参数验证失败 |
| NOT_FOUND | 404 | 资源不存在 |
| INTERNAL_ERROR | 500 | 服务器内部错误 |
| QUOTA_EXCEEDED | 429 | 导出额度已用尽 |
| DEPENDENCY_MISSING | 501 | 缺少必要依赖 |

## 备注

- 若设置环境变量 `SUPABASE_URL` 与 `SUPABASE_KEY`，接口将使用 Supabase 表；否则使用本地 SQLite 文件 `spider.db`。
- 公共池在初始化时自动创建 `public`，可直接使用。
