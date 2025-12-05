ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 0;
ALTER TABLE tasks ADD COLUMN created_by_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE users ADD COLUMN quota_tasks_per_day INTEGER DEFAULT 20;
ALTER TABLE users ADD COLUMN tasks_created_today INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN last_tasks_quota_reset DATE;

CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority DESC);
