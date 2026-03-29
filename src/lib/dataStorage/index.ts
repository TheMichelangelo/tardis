import { appConfig } from '../../config/appConfig';
import { jsonDataStorage } from './jsonDataStorage';
import { sqliteDataStorage } from './sqliteDataStorage';
import { DataStorageProvider } from './types';

export function getDataStorageProvider(): DataStorageProvider {
  if (appConfig.dataStorage === 'sqlite') {
    return sqliteDataStorage;
  }

  return jsonDataStorage;
}
