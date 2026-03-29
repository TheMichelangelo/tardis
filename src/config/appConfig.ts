export type AppLanguage = 'en' | 'ua';
export type AppDataStorage = 'json' | 'sqlite';

export const appConfig = {
  currentLanguage: 'ua' as AppLanguage,
  dataStorage: 'json' as AppDataStorage
};
