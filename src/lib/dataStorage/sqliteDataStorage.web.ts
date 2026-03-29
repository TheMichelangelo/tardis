// Web-safe stub for SQLite storage
// This file prevents SQLite imports during web builds

export const sqliteDataStorage = {
  async loadLessonsFileForClass() {
    throw new Error('SQLite storage not supported in web');
  },
  async saveLessonsFileForClass() {
    throw new Error('SQLite storage not supported in web');
  },
  async loadNavigationState() {
    throw new Error('SQLite storage not supported in web');
  },
  async saveNavigationState() {
    throw new Error('SQLite storage not supported in web');
  },
  async authenticateUser() {
    throw new Error('SQLite storage not supported in web');
  },
  async loadAuthSession() {
    throw new Error('SQLite storage not supported in web');
  },
  async saveAuthSession() {
    throw new Error('SQLite storage not supported in web');
  }
};
