# Price Memory API 文档

## API 概述

Price Memory 后端基于 FastAPI 框架构建，提供 RESTful API 接口用于商品价格监控和数据管理。所有API接口支持JSON格式的请求和响应。

### 基础信息
- **Base URL**: `http://localhost:8000/api/v1`
- **认证方式**: JWT Bearer Token
- **内容类型**: `application/json`
- **API版本**: v1.0.0

### 通用响应格式
```json
{
  "success": true,
  "data": {},
  "message": "操作成功",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 错误响应格式
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "请求参数验证失败",
    "details": []
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 认证接口

### 用户登录
```http
POST /auth/login
```

**请求体**:
```json
{
  "username": "admin",
  "password": "password123"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@example.com",
      "role": "admin"
    }
  }
}
```

### 刷新Token
```http
POST /auth/refresh
```

**请求头**:
```
Authorization: Bearer <refresh_token>
```

## 商品管理接口

### 获取商品列表
```http
GET /products
```

**查询参数**:
- `page`: 页码 (默认: 1)
- `size`: 每页数量 (默认: 20)
- `category`: 商品分类
- `search`: 搜索关键词

**响应**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "name": "iPhone 15 Pro",
        "url": "https://example.com/product/1",
        "category": "电子产品",
        "current_price": 7999.00,
        "currency": "CNY",
        "last_updated": "2024-01-01T12:00:00Z",
        "created_at": "2024-01-01T00:00:00Z"
      }
    ],
    "total": 100,
    "page": 1,
    "size": 20,
    "pages": 5
  }
}
```

### 添加商品
```http
POST /products
```

**请求体**:
```json
{
  "name": "iPhone 15 Pro",
  "url": "https://example.com/product/1",
  "category": "电子产品",
  "selector": ".price",
  "description": "苹果最新旗舰手机"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "iPhone 15 Pro",
    "url": "https://example.com/product/1",
    "category": "电子产品",
    "status": "active",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

### 获取商品详情
```http
GET /products/{product_id}
```

**路径参数**:
- `product_id`: 商品ID

**响应**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "iPhone 15 Pro",
    "url": "https://example.com/product/1",
    "category": "电子产品",
    "current_price": 7999.00,
    "price_history": [
      {
        "price": 8999.00,
        "recorded_at": "2024-01-01T00:00:00Z"
      },
      {
        "price": 7999.00,
        "recorded_at": "2024-01-02T00:00:00Z"
      }
    ],
    "statistics": {
      "min_price": 7999.00,
      "max_price": 8999.00,
      "avg_price": 8499.00,
      "price_change": -1000.00,
      "change_percentage": -11.11
    }
  }
}
```

### 更新商品
```http
PUT /products/{product_id}
```

**请求体**:
```json
{
  "name": "iPhone 15 Pro Max",
  "category": "电子产品",
  "selector": ".new-price",
  "status": "active"
}
```

### 删除商品
```http
DELETE /products/{product_id}
```

## 价格记录接口

### 获取价格历史
```http
GET /products/{product_id}/prices
```

**查询参数**:
- `start_date`: 开始日期 (YYYY-MM-DD)
- `end_date`: 结束日期 (YYYY-MM-DD)
- `interval`: 时间间隔 (hour/day/week/month)

**响应**:
```json
{
  "success": true,
  "data": {
    "product_id": 1,
    "prices": [
      {
        "price": 7999.00,
        "currency": "CNY",
        "recorded_at": "2024-01-01T00:00:00Z",
        "source": "official_website"
      }
    ],
    "statistics": {
      "count": 100,
      "min_price": 7999.00,
      "max_price": 8999.00,
      "avg_price": 8499.00
    }
  }
}
```

### 手动添加价格记录
```http
POST /products/{product_id}/prices
```

**请求体**:
```json
{
  "price": 7999.00,
  "currency": "CNY",
  "source": "manual",
  "note": "手动录入价格"
}
```

## 爬虫任务接口

### 获取爬虫任务列表
```http
GET /spider/tasks
```

**查询参数**:
- `status`: 任务状态 (pending/running/completed/failed)
- `product_id`: 商品ID

**响应**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "product_id": 1,
        "status": "completed",
        "scheduled_at": "2024-01-01T00:00:00Z",
        "started_at": "2024-01-01T00:01:00Z",
        "completed_at": "2024-01-01T00:02:00Z",
        "result": {
          "price": 7999.00,
          "success": true,
          "error": null
        }
      }
    ]
  }
}
```

### 创建爬虫任务
```http
POST /spider/tasks
```

**请求体**:
```json
{
  "product_id": 1,
  "scheduled_at": "2024-01-01T12:00:00Z",
  "priority": "normal"
}
```

### 立即执行爬虫任务
```http
POST /spider/tasks/{task_id}/execute
```

**响应**:
```json
{
  "success": true,
  "data": {
    "task_id": 1,
    "status": "running",
    "started_at": "2024-01-01T00:00:00Z"
  }
}
```

## 统计分析接口

### 获取价格趋势
```http
GET /analytics/price-trends
```

**查询参数**:
- `product_ids`: 商品ID列表 (逗号分隔)
- `period`: 时间周期 (7d/30d/90d/1y)
- `interval`: 数据间隔 (hour/day/week)

**响应**:
```json
{
  "success": true,
  "data": {
    "trends": [
      {
        "product_id": 1,
        "product_name": "iPhone 15 Pro",
        "data_points": [
          {
            "date": "2024-01-01",
            "price": 7999.00,
            "change": -1000.00,
            "change_percentage": -11.11
          }
        ]
      }
    ]
  }
}
```

### 获取价格分布
```http
GET /analytics/price-distribution
```

**查询参数**:
- `category`: 商品分类
- `period`: 时间周期

**响应**:
```json
{
  "success": true,
  "data": {
    "distribution": [
      {
        "price_range": "0-1000",
        "count": 10,
        "percentage": 20.0
      },
      {
        "price_range": "1000-5000",
        "count": 25,
        "percentage": 50.0
      }
    ]
  }
}
```

## 系统管理接口

### 获取系统状态
```http
GET /system/status
```

**响应**:
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "version": "1.0.0",
    "uptime": 86400,
    "database": {
      "status": "connected",
      "connections": 5
    },
    "redis": {
      "status": "connected",
      "memory_usage": "10MB"
    },
    "spider": {
      "active_tasks": 3,
      "completed_today": 150
    }
  }
}
```

### 获取系统配置
```http
GET /system/config
```

**响应**:
```json
{
  "success": true,
  "data": {
    "spider": {
      "max_concurrent_tasks": 10,
      "request_delay": 1000,
      "timeout": 30000
    },
    "cache": {
      "ttl": 3600,
      "max_size": "100MB"
    }
  }
}
```

## 错误代码

| 错误代码 | HTTP状态码 | 描述 |
|---------|-----------|------|
| VALIDATION_ERROR | 400 | 请求参数验证失败 |
| UNAUTHORIZED | 401 | 未授权访问 |
| FORBIDDEN | 403 | 权限不足 |
| NOT_FOUND | 404 | 资源不存在 |
| CONFLICT | 409 | 资源冲突 |
| RATE_LIMITED | 429 | 请求频率超限 |
| INTERNAL_ERROR | 500 | 服务器内部错误 |
| SERVICE_UNAVAILABLE | 503 | 服务不可用 |

## 使用示例

### Python 客户端示例
```python
import httpx

class PriceMemoryClient:
    def __init__(self, base_url: str, token: str):
        self.base_url = base_url
        self.headers = {"Authorization": f"Bearer {token}"}
    
    async def get_products(self, page: int = 1, size: int = 20):
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.base_url}/products",
                params={"page": page, "size": size},
                headers=self.headers
            )
            return response.json()
    
    async def add_product(self, product_data: dict):
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/products",
                json=product_data,
                headers=self.headers
            )
            return response.json()

# 使用示例
client = PriceMemoryClient("http://localhost:8000/api/v1", "your-token")
products = await client.get_products()
```

### JavaScript 客户端示例
```javascript
class PriceMemoryAPI {
  constructor(baseURL, token) {
    this.baseURL = baseURL;
    this.headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };
  }

  async getProducts(page = 1, size = 20) {
    const response = await fetch(
      `${this.baseURL}/products?page=${page}&size=${size}`,
      { headers: this.headers }
    );
    return response.json();
  }

  async addProduct(productData) {
    const response = await fetch(`${this.baseURL}/products`, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify(productData)
    });
    return response.json();
  }
}

// 使用示例
const api = new PriceMemoryAPI('http://localhost:8000/api/v1', 'your-token');
const products = await api.getProducts();
```