CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email_hash TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  place_of_work TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS auth_session (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  user_id TEXT,
  place_of_work TEXT,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
