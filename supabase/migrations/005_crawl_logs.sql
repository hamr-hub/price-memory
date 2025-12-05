CREATE TABLE crawl_logs (
    id SERIAL PRIMARY KEY,
    job_id TEXT NOT NULL,
    node_id INTEGER REFERENCES runtime_nodes(id) ON DELETE SET NULL,
    level TEXT NOT NULL DEFAULT 'info',
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE crawl_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY crawl_logs_select ON crawl_logs FOR SELECT USING (true);
CREATE POLICY crawl_logs_manage ON crawl_logs FOR ALL USING (true) WITH CHECK (true);

CREATE INDEX idx_crawl_logs_job_id_created ON crawl_logs(job_id, created_at);
