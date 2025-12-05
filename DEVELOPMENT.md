# Price Memory 项目开发指南

## 项目概述

Price Memory（价格记忆）是一个商品价格监控与分析系统，帮助用户跟踪商品价格变化，做出更明智的购买决策。

## 技术架构

### 后端 (spider/)
- **框架**: FastAPI
- **数据库**: Supabase (PostgreSQL)
- **爬虫**: Playwright
- **语言**: Python 3.12+

### 前端 (admin/)
- **框架**: React + TypeScript
- **UI库**: Ant Design
- **管理框架**: Refine
- **构建工具**: Vite

### 数据库
- **主数据库**: Supabase PostgreSQL
- **实时功能**: Supabase Realtime
- **认证**: Supabase Auth

## 快速开始

### 1. 环境准备

#### 系统要求
- Python 3.12+
- Node.js 18+
- Git

#### 推荐工具
- Python: `uv` (包管理器)
- Node.js: `pnpm` (包管理器)

### 2. 克隆项目

```bash
git clone https://github.com/hamr-hub/price-memory.git
cd price-memory
```

### 3. 后端设置

```bash
cd spider

# 安装依赖 (推荐使用uv)
uv sync
# 或使用pip
pip install -r requirements.txt

# 安装Playwright浏览器
uv run playwright install
# 或
playwright install

# 复制环境配置
cp .env.example .env
# 编辑.env文件，配置Supabase连接信息
```

### 4. 前端设置

```bash
cd admin

# 安装依赖 (推荐使用pnpm)
pnpm install
# 或使用npm
npm install

# 创建环境配置
echo "VITE_API_URL=http://localhost:8000/api/v1" > .env.local
```

### 5. 数据库设置

1. 在 [Supabase](https://supabase.com) 创建新项目
2. 在SQL编辑器中执行 `supabase/schema.sql`
3. 配置RLS策略（执行 `supabase/policies_and_rpc.sql`）
4. 更新 `spider/.env` 中的数据库连接信息

### 6. 启动服务

#### 方式一：使用启动脚本（推荐）

```bash
python start_dev.py
```

#### 方式二：手动启动

```bash
# 启动后端 (终端1)
cd spider
uv run uvicorn main:app --reload --port 8000

# 启动前端 (终端2)
cd admin
pnpm dev
```

### 7. 访问应用

- 前端管理界面: http://localhost:5173
- 后端API文档: http://localhost:8000/docs
- 后端健康检查: http://localhost:8000/health

## 项目结构

```
price-memory/
├── admin/                  # 前端管理界面
│   ├── src/
│   │   ├── api.ts         # API客户端
│   │   ├── App.tsx        # 主应用组件
│   │   ├── components/    # 组件
│   │   ├── pages/         # 页面
│   │   └── providers/     # 数据提供者
│   ├── package.json
│   └── vite.config.ts
├── spider/                 # 后端API服务
│   ├── src/
│   │   ├── api/          # API路由
│   │   ├── config/       # 配置
│   │   ├── dao/          # 数据访问层
│   │   ├── playwrite/    # 浏览器自动化
│   │   ├── runtime/      # 运行时管理
│   │   ├── services/     # 业务服务
│   │   ├── sites/        # 网站适配器
│   │   ├── utils/        # 工具函数
│   │   └── workers/      # 工作进程
│   ├── main.py           # 应用入口
│   └── pyproject.toml
├── supabase/              # 数据库脚本
│   ├── schema.sql        # 表结构
│   ├── policies_and_rpc.sql # 策略和函数
│   └── migrations/       # 迁移脚本
├── docs/                  # 文档
├── scripts/              # 部署脚本
└── start_dev.py          # 开发环境启动脚本
```

## 核心功能

### 1. 商品管理
- 添加/编辑/删除商品
- 商品分类管理
- 批量操作

### 2. 价格监控
- 自动价格抓取
- 价格历史记录
- 价格趋势分析

### 3. 告警系统
- 价格阈值告警
- 百分比变化告警
- 多渠道通知（邮件、Webhook、站内消息）

### 4. 协作功能
- 公共商品池
- 用户集合
- 商品分享

### 5. 数据导出
- CSV导出
- Excel导出
- 批发指南

### 后端开发

#### 添加新的API端点

1. 在 `spider/src/api/routes.py` 中添加路由
2. 定义Pydantic模型
3. 实现业务逻辑
4. 添加错误处理

```python
@router.post("/products")
def create_product(body: ProductCreate):
    try:
        result = repo.upsert_product(
            name=body.name,
            url=body.url,
            category=body.category
        )
        return ok(result)
    except Exception as e:
        return error_response(500, "INTERNAL_ERROR", str(e))
```

#### 添加新的爬虫站点

1. 在 `spider/src/sites/` 中创建站点适配器
2. 实现价格提取逻辑
3. 在 `spider/src/workers/` 中集成

### 前端开发

#### 添加新页面

1. 在 `admin/src/pages/` 中创建页面组件
2. 在 `admin/src/App.tsx` 中添加路由
3. 配置权限控制

#### 添加新的数据提供者

1. 在 `admin/src/dataProvider.ts` 中添加资源处理
2. 实现CRUD操作
3. 处理过滤和排序

## 配置说明

### 环境变量

#### 后端配置 (spider/.env)

```bash
# Supabase配置
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key

# Playwright配置
PLAYWRIGHT_WS_ENDPOINT=ws://localhost:20001/
BROWSER_MODE=remote

# 节点配置
NODE_NAME=node-local
NODE_CONCURRENCY=1
AUTO_CONSUME_QUEUE=false

# SMTP配置（可选）
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
```

#### 前端配置 (admin/.env.local)

```bash
VITE_API_URL=http://localhost:8000/api/v1
```

## 部署指南

### Docker部署

```bash
# 构建镜像
docker build -t price-memory-api ./spider
docker build -t price-memory-admin ./admin

# 运行容器
docker run -d -p 8000:8000 --env-file spider/.env price-memory-api
docker run -d -p 5173:5173 price-memory-admin
```

### 生产环境

1. 配置反向代理（Nginx）
2. 设置SSL证书
3. 配置环境变量
4. 设置监控和日志

## 常见问题

### 1. API连接失败

- 检查后端服务是否启动
- 确认端口配置正确
- 检查防火墙设置

### 2. 数据库连接失败

- 验证Supabase配置
- 检查网络连接
- 确认数据库权限

### 3. 爬虫无法工作

- 检查Playwright安装
- 验证浏览器连接
- 查看错误日志

## 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 创建Pull Request

## 许可证

MIT License

## 联系方式

- 项目地址: https://github.com/hamr-hub/price-memory
- 问题反馈: https://github.com/hamr-hub/price-memory/issues