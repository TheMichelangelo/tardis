import { AppLanguage } from '../config/appConfig';
import { getDataStorageProvider } from './dataStorage';
import { ClassLessonsFile, ClassNumber } from './types';

export async function loadLessonsFileForClass(
  classNumber: ClassNumber,
  language: AppLanguage
): Promise<ClassLessonsFile> {
  return getDataStorageProvider().loadLessonsFileForClass(classNumber, language);
}

export async function saveLessonsFileForClass(
  classNumber: ClassNumber,
  language: AppLanguage,
  data: ClassLessonsFile
) {
  await getDataStorageProvider().saveLessonsFileForClass(classNumber, language, data);
}

export async function loadNavigationState<T>(): Promise<T | null> {
  return getDataStorageProvider().loadNavigationState<T>();
}

export async function saveNavigationState<T>(data: T) {
  await getDataStorageProvider().saveNavigationState(data);
}
