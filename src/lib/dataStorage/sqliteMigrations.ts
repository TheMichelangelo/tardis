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
  }
];
