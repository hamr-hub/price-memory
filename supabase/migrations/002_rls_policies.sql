-- Row Level Security (RLS) Policies for Price Memory
-- Migration: 002_rls_policies.sql

-- Enable RLS on all tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE pushes ENABLE ROW LEVEL SECURITY;
ALTER TABLE pools ENABLE ROW LEVEL SECURITY;
ALTER TABLE pool_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE collection_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE collection_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

-- Products: 公开读取，认证用户可以创建
CREATE POLICY "Products are viewable by everyone" ON products
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create products" ON products
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update their own products" ON products
    FOR UPDATE USING (auth.uid()::text = created_by::text);

-- Prices: 公开读取，系统可以插入
CREATE POLICY "Prices are viewable by everyone" ON prices
    FOR SELECT USING (true);

CREATE POLICY "System can insert prices" ON prices
    FOR INSERT WITH CHECK (true);

-- Tasks: 管理员可以查看和管理
CREATE POLICY "Admins can view all tasks" ON tasks
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "System can manage tasks" ON tasks
    FOR ALL USING (true);

-- Users: 用户可以查看自己的信息
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- User follows: 用户可以管理自己的关注
CREATE POLICY "Users can view own follows" ON user_follows
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can manage own follows" ON user_follows
    FOR ALL USING (auth.uid()::text = user_id::text);

-- Pushes: 用户可以查看发送给自己的推送
CREATE POLICY "Users can view received pushes" ON pushes
    FOR SELECT USING (auth.uid()::text = recipient_id::text);

CREATE POLICY "Users can send pushes" ON pushes
    FOR INSERT WITH CHECK (auth.uid()::text = sender_id::text);

-- Pools: 公开池可以被所有人查看
CREATE POLICY "Public pools are viewable by everyone" ON pools
    FOR SELECT USING (is_public = true);

CREATE POLICY "Authenticated users can create pools" ON pools
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Pool products: 基于池的可见性
CREATE POLICY "Pool products follow pool visibility" ON pool_products
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM pools 
            WHERE pools.id = pool_products.pool_id 
            AND pools.is_public = true
        )
    );

-- Collections: 用户可以管理自己的收藏夹
CREATE POLICY "Users can view own collections" ON collections
    FOR SELECT USING (auth.uid()::text = owner_user_id::text);

CREATE POLICY "Users can manage own collections" ON collections
    FOR ALL USING (auth.uid()::text = owner_user_id::text);

CREATE POLICY "Public collections are viewable by everyone" ON collections
    FOR SELECT USING (is_public = true);

-- Collection products: 基于收藏夹的可见性
CREATE POLICY "Collection products follow collection visibility" ON collection_products
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM collections 
            WHERE collections.id = collection_products.collection_id 
            AND (collections.is_public = true OR auth.uid()::text = collections.owner_user_id::text)
        )
    );

-- Collection members: 成员可以查看自己参与的收藏夹
CREATE POLICY "Members can view collection memberships" ON collection_members
    FOR SELECT USING (auth.uid()::text = user_id::text);

-- Alerts: 用户只能管理自己的提醒
CREATE POLICY "Users can manage own alerts" ON alerts
    FOR ALL USING (auth.uid()::text = user_id::text);