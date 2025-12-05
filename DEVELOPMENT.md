# Price Memory 项目开发指南

## 项目概述

Price Memory（价格记忆）是一个商品价格监控与分析系统，帮助用户跟踪商品价格变化，做出更明智的购买决策。

## 技术架构

### 后端 (spider/)
- **框架**: FastAPI
- **数据库**: Supabase (PostgreSQL)
- **爬虫**: Playwright
- **语言**: Python 3.12+
- **任务调度**: 自研任务调度器
- **价格监控**: 实时价格变化检测
- **告警系统**: 多渠道告警推送

### 前端 (admin/)
- **框架**: React + TypeScript
- **UI库**: Ant Design
- **管理框架**: Refine
- **构建工具**: Vite
- **状态管理**: React Query

### 数据库
- **主数据库**: Supabase PostgreSQL
- **实时功能**: Supabase Realtime
- **认证**: Supabase Auth

## 核心功能

### 🛍️ 商品管理
- 支持Amazon、淘宝、京东等主流电商平台
- 自动商品信息提取和更新
- 商品分类和标签管理
- 批量商品导入和管理

### 📊 价格监控
- 实时价格抓取和更新
- 价格历史记录和趋势分析
- 智能价格变化检测
- 多货币支持

### 🔔 告警系统
- 价格阈值告警
- 百分比变化告警
- 多渠道推送（邮件、Webhook、站内消息）
- 告警冷却机制

### ⚙️ 任务调度
- 智能任务调度和优先级管理
- 失败重试机制
- 并发控制和负载均衡
- 任务状态监控

### 👥 协作功能
- 用户管理和权限控制
- 商品收藏和分享
- 公共商品池
- API密钥管理

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
git clone https://github.com/hamr-hub/price-memory.ge-memory
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

#### 方式一：自动初始化（推荐）

```bash
cd spider
# 配置.env文件中的Supabase连接信息
python init_database.py
```

#### 方式二：手动设置

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

## 生产部署

### Docker 部署（推荐）

```bash
# 设置部署环境
./deploy.sh setup

# 编辑生产环境配置
vim deploy/production/.env

# 部署应用
./deploy.sh deploy

# 查看服务状态
./deploy.sh status

# 查看日志
./deploy.sh logs
```

### 手动部署

参考 `deploy.sh` 脚本中的配置，手动设置 Nginx、Docker 等服务。

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
│   ├── Dockerfile         # Docker构建文件
│   └── vite.config.ts
├── spider/                 # 后端API服务
│   ├── src/
│   │   ├── api/          # API路由
│   │   ├── config/       # 配置管理
│   │   ├── dao/          # 数据访问层
│   │   ├── playwrite/    # 浏览器自动化
│   │   ├── runtime/      # 运行时管理
│   │   ├── services/     # 业务服务
│   │   │   ├── price_monitor.py    # 价格监控
│   │   │   └── task_scheduler.py   # 任务调度
│   │   ├── sites/        # 网站适配器
│   │   │   ├── amazon.py          # Amazon适配器
│   │   │   ├── taobao.py          # 淘宝适配器
│   │   │   ├── jd.py              # 京东适配器
│   │   │   └── universal.py       # 通用适配器
│   │   ├── utils/        # 工具函数
│   │   └── workers/      # 工作进程
│   ├── main.py           # 应用入口
│   ├── init_database.py  # 数据库初始化
│   ├── Dockerfile        # Docker构建文件
│   └── pyproject.toml
├── supabase/              # 数据库脚本
│   ├── schema.sql        # 表结构
│   ├── policies_and_rpc.sql # 策略和函数
│   └── migrations/       # 迁移脚本
├── deploy/               # 部署配置
│   └── production/       # 生产环境配置
├── docs/                 # 文档
├── start_dev.py         # 开发环境启动脚本
├── deploy.sh            # 部署脚本
└── DEVELOPMENT.md       # 开发指南
```

## 支持的电商平台

### 🌍 国际平台
- **Amazon** (美国、英国、德国、法国、意大利、西班牙、加、日本、印度等)
- **eBay** (通用支持)
- **AliExpress** (通用支持)

### 🇨🇳 国内平台
- **淘宝** (Taobao)
- **天猫** (Tmall)
- **京东** (JD.com)
- **拼多多** (通用支持)
- **苏宁易购** (通用支持)

### 🔧 通用支持
- 任何包含价格信息的电商网站
- 自动价格检测和提取
- 智能货币识别

## 核心功能详解

### 1. 智能价格抓取
- **多平台支持**: 支持主流电商平台的价格抓取
- **智能解析**: 自动识别价格、货币、商品信息
- **反爬虫对抗**: 代理轮换、请求头伪装、延迟控制
- **错误处理**: 完善的重试机制和错误恢复

### 2. 实时价格监控
- **变化检测**: 实时检测价格变化
- **历史记录**: 完整的价格历史数据
- **趋势分析**: 价格走势图表和统计
- **预测功能**: 基于历史数据的价格预测

### 3. 智能告警系统
- **多种规则**: 阈值告警、百分比变化、价格区间
- **多渠道推送**: 邮件、Webhook、站内消息、短信
- **冷却机制**: 防止告警轰炸
- **个性化设置**: 用户自定义告警规则

### 4. 任务调度系统
- **智能调度**: 基于优先级和负载的任务分配
- **并发控制**: 可配置的并发数量和速率限制
- **失败重试**: 指数退避重试策略
- **监控统计**: 详细的任务执行统计和监控

### 5. 用户协作
- **权限管理**: 基于角色的访问控制
- **商品分享**: 公共商品池和私人收藏
- **API接口**: 完整的RESTful API
- **数据导出**: 多格式数据导出功能

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