-- Sample data for Price Memory
-- Migration: 003_sample_data.sql

-- Insert sample users
INSERT INTO users (username, display_name, email) VALUES
('admin', '管理员', 'admin@pricememory.com'),
('user1', '用户一', 'user1@example.com'),
('user2', '用户二', 'user2@example.com');

-- Insert sample products
INSERT INTO products (name, url, category) VALUES
('iPhone 15 Pro', 'https://www.apple.com/iphone-15-pro/', '电子产品'),
('MacBook Air M2', 'https://www.apple.com/macbook-air/', '电子产品'),
('AirPods Pro', 'https://www.apple.com/airpods-pro/', '电子产品'),
('Nike Air Max 270', 'https://www.nike.com/air-max-270', '运动鞋'),
('Adidas Ultraboost 22', 'https://www.adidas.com/ultraboost-22', '运动鞋');

-- Insert sample price records
INSERT INTO prices (product_id, price, currency) VALUES
(1, 7999.00, 'CNY'),
(1, 7899.00, 'CNY'),
(1, 7799.00, 'CNY'),
(2, 8999.00, 'CNY'),
(2, 8799.00, 'CNY'),
(3, 1899.00, 'CNY'),
(3, 1799.00, 'CNY'),
(4, 1299.00, 'CNY'),
(4, 1199.00, 'CNY'),
(5, 1599.00, 'CNY');

-- Insert sample tasks
INSERT INTO tasks (product_id, status, scheduled_at) VALUES
(1, 'completed', NOW() - INTERVAL '1 hour'),
(2, 'pending', NOW() + INTERVAL '1 hour'),
(3, 'running', NOW()),
(4, 'completed', NOW() - INTERVAL '2 hours'),
(5, 'pending', NOW() + INTERVAL '2 hours');

-- Insert sample user follows
INSERT INTO user_follows (user_id, product_id) VALUES
(2, 1),
(2, 2),
(3, 1),
(3, 3),
(3, 4);

-- Insert sample pools
INSERT INTO pools (name, is_public, description) VALUES
('热门电子产品', true, '当前最受关注的电子产品价格监控'),
('运动装备', true, '运动鞋和运动装备价格追踪'),
('私人收藏', false, '个人关注的商品列表');

-- Insert sample pool products
INSERT INTO pool_products (pool_id, product_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 4),
(2, 5),
(3, 1);

-- Insert sample collections
INSERT INTO collections (name, owner_user_id, description, is_public) VALUES
('我的电子产品', 2, '个人关注的电子产品', false),
('公共推荐', 1, '管理员推荐的热门商品', true),
('运动爱好者', 3, '运动相关商品收藏', true);

-- Insert sample collection products
INSERT INTO collection_products (collection_id, product_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 1),
(2, 4),
(3, 4),
(3, 5);

-- Insert sample collection members
INSERT INTO collection_members (collection_id, user_id, role) VALUES
(2, 2, 'viewer'),
(2, 3, 'viewer'),
(3, 2, 'editor');

-- Insert sample alerts
INSERT INTO alerts (user_id, product_id, rule_type, threshold, percent, status) VALUES
(2, 1, 'price_target', 7500.00, NULL, 'active'),
(2, 2, 'percent_drop', NULL, 10.00, 'active'),
(3, 1, 'price_drop', NULL, NULL, 'active'),
(3, 4, 'price_target', 1000.00, NULL, 'active');