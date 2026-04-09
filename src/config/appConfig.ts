export type AppLanguage = 'en' | 'ua';
export type AppDataStorage = 'json' | 'sqlite';

export const appConfig = {
  currentLanguage: 'ua' as AppLanguage,
  dataStorage: 'json' as AppDataStorage,
  webBasePath: '/tardis'
};

export function getActiveWebBasePath() {
  if (typeof window === 'undefined') {
    return appConfig.webBasePath;
  }

  const configuredBasePath = appConfig.webBasePath.replace(/\/+$/, '');
  if (!configuredBasePath) {
    return '';
  }

  const { pathname } = window.location;
  return pathname === configuredBasePath || pathname.startsWith(`${configuredBasePath}/`)
    ? configuredBasePath
    : '';
}
