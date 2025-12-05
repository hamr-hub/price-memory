CREATE TABLE runtime_nodes (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    host TEXT,
    region TEXT,
    version TEXT,
    status TEXT NOT NULL DEFAULT 'online',
    current_tasks INTEGER NOT NULL DEFAULT 0,
    queue_size INTEGER NOT NULL DEFAULT 0,
    total_completed INTEGER NOT NULL DEFAULT 0,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE node_commands (
    id SERIAL PRIMARY KEY,
    node_id INTEGER NOT NULL REFERENCES runtime_nodes(id) ON DELETE CASCADE,
    command TEXT NOT NULL,
    payload JSONB,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

ALTER TABLE runtime_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE node_commands ENABLE ROW LEVEL SECURITY;

CREATE POLICY runtime_nodes_select ON runtime_nodes FOR SELECT USING (true);
CREATE POLICY node_commands_select ON node_commands FOR SELECT USING (true);

CREATE POLICY runtime_nodes_upsert ON runtime_nodes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY node_commands_manage ON node_commands FOR ALL USING (true) WITH CHECK (true);

CREATE INDEX idx_runtime_nodes_last_seen ON runtime_nodes(last_seen);
CREATE INDEX idx_node_commands_node_id_status ON node_commands(node_id, status);
