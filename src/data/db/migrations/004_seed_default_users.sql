INSERT INTO users (id, email_hash, password_hash, place_of_work, created_at)
VALUES (
  'teacher-1',
  '$2b$10$h73EI1LJV0L4bkpDNOpKm.9FfyXApLqWQJAsApNM6ySoAVXdXfCSW',
  '$2b$10$P6Fvz3pBnsa2s1vUNBvVZuLSo8VXS5Dld1RdlvpzIhzxqhl5nNQiq',
  'STEM Laboratory',
  CURRENT_TIMESTAMP
)
ON CONFLICT(id) DO NOTHING;

INSERT INTO auth_session (id, user_id, place_of_work, updated_at)
VALUES (1, NULL, NULL, CURRENT_TIMESTAMP)
ON CONFLICT(id) DO NOTHING;
