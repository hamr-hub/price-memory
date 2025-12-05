ALTER TABLE node_commands ADD COLUMN priority INTEGER NOT NULL DEFAULT 0;
ALTER TABLE node_commands ADD COLUMN scheduled_at TIMESTAMP WITH TIME ZONE;
CREATE INDEX idx_node_commands_sched_prio ON node_commands(node_id, status, scheduled_at, priority);
