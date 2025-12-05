ALTER TABLE node_commands ADD COLUMN locked_by INTEGER;
ALTER TABLE node_commands ADD COLUMN locked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE node_commands ADD COLUMN attempt_count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE node_commands ADD COLUMN next_retry_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE node_commands ADD COLUMN error_message TEXT;
CREATE INDEX idx_node_commands_retry ON node_commands(status, next_retry_at);
