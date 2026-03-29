export type SqliteMigration = {
  name: string;
  sql: string;
};

// Keep these SQL strings aligned with the files in src/data/db/migrations.
export const sqliteMigrations: SqliteMigration[] = [
  {
    name: '001_create_storage_tables.sql',
    sql: `
      CREATE TABLE IF NOT EXISTS schema_migrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        applied_at TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS class_lessons (
        class_number INTEGER NOT NULL,
        language TEXT NOT NULL,
        modules_json TEXT NOT NULL,
        lessons_json TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        PRIMARY KEY (class_number, language)
      );

      CREATE TABLE IF NOT EXISTS navigation_state (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        state_json TEXT,
        updated_at TEXT NOT NULL
      );
    `
  },
  {
    name: '002_seed_navigation_state.sql',
    sql: `
      INSERT INTO navigation_state (id, state_json, updated_at)
      VALUES (1, NULL, CURRENT_TIMESTAMP)
      ON CONFLICT(id) DO NOTHING;
    `
  },
  {
    name: '003_create_user_tables.sql',
    sql: `
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
    `
  },
  {
    name: '004_seed_default_users.sql',
    sql: `
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
    `
  }
];
