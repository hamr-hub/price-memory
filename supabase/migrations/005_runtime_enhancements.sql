ALTER TABLE runtime_nodes ADD COLUMN IF NOT EXISTS latency_ms INTEGER;
ALTER TABLE runtime_nodes ADD COLUMN IF NOT EXISTS concurrency INTEGER DEFAULT 1;

ALTER TABLE node_commands ADD COLUMN IF NOT EXISTS priority INTEGER DEFAULT 0;
ALTER TABLE node_commands ADD COLUMN IF NOT EXISTS scheduled_at TIMESTAMP WITH TIME ZONE;

CREATE TABLE IF NOT EXISTS crawl_logs (
  id SERIAL PRIMARY KEY,
  node_id INTEGER REFERENCES runtime_nodes(id) ON DELETE SET NULL,
  job_id TEXT,
  level TEXT,
  message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE crawl_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY crawl_logs_select ON crawl_logs FOR SELECT USING (true);
CREATE INDEX IF NOT EXISTS idx_crawl_logs_job_id ON crawl_logs(job_id);
