ALTER TABLE runtime_nodes ADD COLUMN latency_ms INTEGER;
ALTER TABLE runtime_nodes ADD COLUMN weight INTEGER DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_runtime_nodes_latency ON runtime_nodes(latency_ms);
