# Supabase 数据库架构与技术说明

## 概述
- 目标：将价格监控与协作功能迁移到 Supabase（Postgres + Auth + Realtime + Storage），实现统一、可扩展、可授权的数据层。
- 范围：公共 `public` schema 下的业务表、RLS 策略、索引与实时订阅，以及与现有后端/前端的映射与使用方式。

## 核心实体
- profiles：用户档案（映射到 `auth.users`），含显示名、套餐、配额与 API Key。
- products：商品主数据（名称、链接、来源域、分类）。
- prices：价格快照（含币种与时间），用于趋势与导出。
- tasks：采集任务（调度、执行、结果状态）。
- user_follows：用户关注商品集合。
- pushes：站内通知与告警投递记录。
- pools：协作池（支持公共池与私有池）。
- pool_products：协作池内商品。
- collections：用户集合（清单）。
- collection_products：集合内商品。
- collection_members：集合成员与角色。
- alerts：价格告警规则（阈值/百分比，状态）。

## 存储设计
- 用户使用 Supabase Auth，业务层以 `profiles.id`（UUID）作为外键；与 `auth.users.id` 一致。
- 商品与价格采用 `bigint identity` 作为主键，价格用 `numeric(12,2)` 存储，保留币种 `currency`。
- 所有一对多、多对多关系通过外键与唯一约束保证一致性（如 `unique(user_id, product_id)`）。
- 变更时间字段统一 `created_at`、`updated_at`，并用触发器自动维护 `updated_at`。
- 导出文件与图片类资源建议存储在 Supabase Storage：`exports`、`images` 两个 bucket。

## 权限与 RLS
- profiles：用户仅可读写自己的档案（`id = auth.uid()`）。
- products：已启用 RLS，对 `authenticated` 开放只读；写入由服务密钥或后台服务完成。
- prices：对 `authenticated` 开放只读；写入由后台采集服务完成。
- tasks：对 `authenticated` 开放只读；写入由后台采集服务完成。
- user_follows：仅用户自身可读写删除自己的关注记录。
- pushes：仅接收者可读与更新状态。
- pools：公开池所有用户可读；仅所有者可增删改。
- pool_products：公开池可读；仅池所有者可增删。
- collections：所有者可读写删；成员可读（通过成员子查询策略）。
- collection_products：成员可读；仅集合所有者可增删。
- collection_members：成员可读自身；集合所有者可管理成员。
- alerts：仅用户自身可读写删。

## 索引与性能
- prices：`(product_id, created_at desc)` 覆盖趋势与时间序查询。
- tasks：`(product_id)` 支持按商品检索任务。
- 唯一约束：`user_follows(user_id, product_id)`、`pool_products(pool_id, product_id)`、`collection_products(collection_id, product_id)`、`collection_members(collection_id, user_id)`。
- 选择性索引：`pushes(recipient_id, status)`、`collections(owner_user_id)`。
- 搜索优化：启用 `pg_trgm`，建立 `products(name,url)` 的 GIN trigram 索引。

## 实时订阅
- `public.prices` 已加入 `supabase_realtime` 发布，前端可订阅价格变化以刷新趋势与图表。
- 推荐在前端使用 `on('postgres_changes', ...)` 订阅 `prices`、必要时订阅 `products`。

## 与现有逻辑的映射
- 采集任务执行后写入 `prices`；趋势/导出接口读取 `prices`。
- 告警规则从 `alerts` 读取；告警触发写入 `pushes` 并由前端或后台通知用户。
- 公共池与选择逻辑通过 `pools`、`pool_products` 表实现；用户关注走 `user_follows`。
- 集合与协作使用 `collections`、`collection_products`、`collection_members` 三表与 RLS 保证多方权限。
 - 辅助视图：`v_latest_prices` 提供每商品最新价格；`v_user_follow_products` 提供关注商品明细。

## 初始化与迁移
- 执行 `supabase/schema.sql` 中的 DDL 在 Supabase SQL Editor 或 CI 初始化环境。
- 创建 Storage bucket：`exports`、`images` 并配置公开/受限访问策略视业务需要。
- 将后台采集服务改为写入 Supabase Postgres（服务密钥环境下绕过 RLS）。
 - 可选：启用 `pg_trgm` 扩展以支持模糊搜索。可创建每日配额重置函数 `reset_daily_quota()`，结合 `pg_cron` 进行计划任务。

## 示例查询
- 查询某商品最近价格：
  - `select price, currency, created_at from public.prices where product_id = $1 order by created_at desc limit 20;`
- 查询关注列表：
  - `select p.* from public.products p join public.user_follows f on f.product_id = p.id where f.user_id = auth.uid();`
- 查询公开池商品：
  - `select pr.* from public.pool_products pp join public.pools pl on pl.id = pp.pool_id and pl.is_public join public.products pr on pr.id = pp.product_id;`
- 查询最新价格视图：
  - `select * from public.v_latest_prices where product_id = $1;`
- 查询我的关注视图：
  - `select * from public.v_user_follow_products where user_id = auth.uid();`

## RPC 示例
- 获取日级价格趋势：
  - `select * from public.rpc_product_daily_prices($1, $2::date, $3::date);`
- 关注商品：
  - `select public.rpc_follow_product($1);`
- 取消关注：
  - `select public.rpc_unfollow_product($1);`

## 备注
- 若需在数据库层实现价格告警触发，可增加 `prices` 插入触发器调用 PL/pgSQL 比较最近价格与阈值后写入 `pushes`；当前建议由后台服务统一评估以便跨站点规则扩展。
