INSERT INTO navigation_state (id, state_json, updated_at)
VALUES (1, NULL, CURRENT_TIMESTAMP)
ON CONFLICT(id) DO NOTHING;
