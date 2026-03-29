import { appConfig } from '../../config/appConfig';
import { jsonDataStorage } from './jsonDataStorage';
import { DataStorageProvider } from './types';

export function getDataStorageProvider(): DataStorageProvider {
  if (appConfig.dataStorage === 'sqlite') {
    // Only import SQLite when actually needed (native platforms)
    if (typeof document === 'undefined') {
      return require('./sqliteDataStorage').sqliteDataStorage;
    } else {
      console.warn('SQLite storage not supported in web, falling back to JSON storage');
    }
  }

  return jsonDataStorage;
}
