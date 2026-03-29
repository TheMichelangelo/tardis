import { authenticateAgainstUsers } from '../auth';
import { AppLanguage } from '../../config/appConfig';
import { AuthUser, ClassLessonsFile, ClassNumber, StoredUser } from '../types';
import { getDefaultLessonsFile, mergeWithLatestConfig } from './defaults';
import { sqliteMigrations } from './sqliteMigrations';
import { DataStorageProvider } from './types';

const SQLITE_DB_NAME = 'stem_lesson_builder.db';

type SQLiteModule = {
  openDatabaseAsync: (name: string) => Promise<SQLiteDatabase>;
};

type SQLiteDatabase = {
  execAsync: (source: string) => Promise<void>;
  getAllAsync: <T>(source: string, ...params: (string | number | null)[]) => Promise<T[]>;
  getFirstAsync: <T>(
    source: string,
    ...params: (string | number | null)[]
  ) => Promise<T | null>;
  runAsync: (source: string, ...params: (string | number | null)[]) => Promise<unknown>;
};

type StoredClassLessonsRow = {
  modules_json: string;
  lessons_json: string;
};

type StoredNavigationStateRow = {
  state_json: string | null;
};

type StoredUserRow = {
  id: string;
  email_hash: string;
  password_hash: string;
  place_of_work: string;
};

type StoredAuthSessionRow = {
  user_id: string | null;
  place_of_work: string | null;
};

let databasePromise: Promise<SQLiteDatabase> | null = null;

async function loadSQLiteModule(): Promise<SQLiteModule> {
  return (await import('expo-sqlite')) as unknown as SQLiteModule;
}

async function runMigrations(db: SQLiteDatabase) {
  await db.execAsync(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      applied_at TEXT NOT NULL
    );
  `);

  const appliedRows = await db.getAllAsync<{ name: string }>('SELECT name FROM schema_migrations');
  const appliedNames = new Set(appliedRows.map((row) => row.name));

  for (const migration of sqliteMigrations) {
    if (appliedNames.has(migration.name)) {
      continue;
    }

    await db.execAsync('BEGIN');
    try {
      await db.execAsync(migration.sql);
      await db.runAsync(
        'INSERT INTO schema_migrations (name, applied_at) VALUES (?, ?)',
        migration.name,
        new Date().toISOString()
      );
      await db.execAsync('COMMIT');
    } catch (error) {
      await db.execAsync('ROLLBACK');
      throw error;
    }
  }
}

async function getDatabase() {
  if (!databasePromise) {
    databasePromise = (async () => {
      const sqlite = await loadSQLiteModule();
      const db = await sqlite.openDatabaseAsync(SQLITE_DB_NAME);
      await runMigrations(db);
      return db;
    })();
  }

  return databasePromise;
}

async function upsertClassLessons(
  db: SQLiteDatabase,
  classNumber: ClassNumber,
  language: AppLanguage,
  data: ClassLessonsFile
) {
  await db.runAsync(
    `
      INSERT INTO class_lessons (class_number, language, modules_json, lessons_json, updated_at)
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(class_number, language) DO UPDATE SET
        modules_json = excluded.modules_json,
        lessons_json = excluded.lessons_json,
        updated_at = excluded.updated_at
    `,
    classNumber,
    language,
    JSON.stringify(data.modules),
    JSON.stringify(data.lessons),
    new Date().toISOString()
  );
}

function parseClassLessonsRow(row: StoredClassLessonsRow): ClassLessonsFile {
  return {
    modules: JSON.parse(row.modules_json) as ClassLessonsFile['modules'],
    lessons: JSON.parse(row.lessons_json) as ClassLessonsFile['lessons']
  };
}

function parseStoredUser(row: StoredUserRow): StoredUser {
  return {
    id: row.id,
    emailHash: row.email_hash,
    passwordHash: row.password_hash,
    placeOfWork: row.place_of_work
  };
}

export const sqliteDataStorage: DataStorageProvider = {
  async loadLessonsFileForClass(classNumber, language) {
    const db = await getDatabase();
    const defaults = getDefaultLessonsFile(classNumber, language);
    const row = await db.getFirstAsync<StoredClassLessonsRow>(
      `
        SELECT modules_json, lessons_json
        FROM class_lessons
        WHERE class_number = ? AND language = ?
      `,
      classNumber,
      language
    );

    if (!row) {
      await upsertClassLessons(db, classNumber, language, defaults);
      return defaults;
    }

    const merged = mergeWithLatestConfig(defaults, parseClassLessonsRow(row));
    await upsertClassLessons(db, classNumber, language, merged);
    return merged;
  },

  async saveLessonsFileForClass(classNumber, language, data) {
    const db = await getDatabase();
    await upsertClassLessons(db, classNumber, language, data);
  },

  async loadNavigationState<T>() {
    const db = await getDatabase();
    const row = await db.getFirstAsync<StoredNavigationStateRow>(
      'SELECT state_json FROM navigation_state WHERE id = 1'
    );

    if (!row?.state_json) {
      return null;
    }

    return JSON.parse(row.state_json) as T;
  },

  async saveNavigationState<T>(data: T) {
    const db = await getDatabase();
    await db.runAsync(
      `
        INSERT INTO navigation_state (id, state_json, updated_at)
        VALUES (1, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          state_json = excluded.state_json,
          updated_at = excluded.updated_at
      `,
      JSON.stringify(data),
      new Date().toISOString()
    );
  },

  async authenticateUser(email, password) {
    const db = await getDatabase();
    const rows = await db.getAllAsync<StoredUserRow>(
      'SELECT id, email_hash, password_hash, place_of_work FROM users'
    );

    return authenticateAgainstUsers(rows.map(parseStoredUser), email, password);
  },

  async loadAuthSession() {
    const db = await getDatabase();
    const row = await db.getFirstAsync<StoredAuthSessionRow>(
      'SELECT user_id, place_of_work FROM auth_session WHERE id = 1'
    );

    if (!row?.user_id || !row.place_of_work) {
      return null;
    }

    return {
      id: row.user_id,
      placeOfWork: row.place_of_work
    };
  },

  async saveAuthSession(user) {
    const db = await getDatabase();
    await db.runAsync(
      `
        INSERT INTO auth_session (id, user_id, place_of_work, updated_at)
        VALUES (1, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          user_id = excluded.user_id,
          place_of_work = excluded.place_of_work,
          updated_at = excluded.updated_at
      `,
      user?.id ?? null,
      user?.placeOfWork ?? null,
      new Date().toISOString()
    );
  }
};
