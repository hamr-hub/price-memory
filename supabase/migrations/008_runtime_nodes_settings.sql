ALTER TABLE runtime_nodes ADD COLUMN concurrency INTEGER;
ALTER TABLE runtime_nodes ADD COLUMN auto_consume BOOLEAN DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_runtime_nodes_concurrency ON runtime_nodes(concurrency);
