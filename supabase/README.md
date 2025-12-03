# Supabase 数据库建表指南

本目录包含了 Price Memory 项目的 Supabase 数据库建表脚本和配置文件。

## 文件结构

```
supabase/
├── migrations/
│   ├── 001_initial_schema.sql    # 基础表结构
│   ├── 002_rls_policies.sql      # 行级安全策略
│   └── 003_sample_data.sql       # 示例数据
├── init_db.py                    # 数据库初始化脚本
└── README.md                     # 本文件
```

## 快速开始

### 方法一：使用 Supabase Dashboard（推荐）

1. 登录 [Supabase Dashboard](https://supabase.com/dashboard)
2. 创建新项目或选择现有项目
3. 进入 SQL Editor
4. 按顺序执行以下 SQL 文件：
   - `migrations/001_initial_schema.sql`
   - `migrations/002_rls_policies.sql`
   - `migrations/003_sample_data.sql`（可选）

### 方法二：使用 Supabase CLI

1. 安装 Supabase CLI：
   ```bash
   npm install -g supabase
   ```

2. 初始化项目：
   ```bash
   supabase init
   ```

3. 将迁移文件复制到 `supabase/migrations/` 目录

4. 推送到数据库：
   ```bash
   supabase db push
   ```

### 方法三：使用 Python 脚本

1. 设置环境变量：
   ```bash
   export SUPABASE_URL="your_supabase_url"
   export SUPABASE_SERVICE_ROLE_KEY="your_service_role_key"
   ```

2. 运行初始化脚本：
   ```bash
   python init_db.py
   ```

## 环境配置

### 前端配置

1. 复制环境变量模板：
   ```bash
   cp admin/.env.example admin/.env.local
   ```

2. 编辑 `admin/.env.local`，填入你的 Supabase 项目信息：
   ```
   VITE_SUPABASE_URL=your_supabase_project_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

### 后端配置

在 `spider` 目录下设置环境变量：
```bash
export SUPABASE_URL="your_supabase_url"
export SUPABASE_KEY="your_supabase_anon_key"
```

## 数据库表结构

### 核心表

- **products**: 商品信息表
- **prices**: 价格记录表
- **tasks**: 爬虫任务表
- **users**: 用户表

### 功能表

- **user_follows**: 用户关注商品
- **pushes**: 推送记录
- **alerts**: 价格提醒
- **pools**: 商品池
- **collections**: 收藏夹

### 关联表

- **pool_products**: 商品池商品关联
- **collection_products**: 收藏夹商品关联
- **collection_members**: 收藏夹成员

## 安全策略

项目使用 Supabase 的行级安全（RLS）策略来保护数据：

- 公开数据：商品信息、价格记录、公开的商品池和收藏夹
- 用户数据：用户只能访问和修改自己的数据
- 管理数据：任务管理需要管理员权限

## 注意事项

1. **Service Role Key**: 用于管理操作，请妥善保管
2. **Anon Key**: 用于客户端连接，可以公开
3. **RLS 策略**: 确保在生产环境中启用行级安全
4. **索引优化**: 已为常用查询字段创建索引

## 故障排除

### 常见问题

1. **连接失败**: 检查 URL 和 Key 是否正确
2. **权限错误**: 确认使用了正确的 Key（Service Role 用于管理，Anon 用于客户端）
3. **RLS 阻止**: 检查行级安全策略是否正确配置

### 获取帮助

- [Supabase 官方文档](https://supabase.com/docs)
- [PostgreSQL 文档](https://www.postgresql.org/docs/)
- 项目 Issues: 在 GitHub 仓库中提交问题