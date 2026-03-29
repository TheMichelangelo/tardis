import { AppLanguage } from '../../config/appConfig';
import { ClassLessonsFile, ClassNumber } from '../types';

export type DataStorageProvider = {
  loadLessonsFileForClass: (
    classNumber: ClassNumber,
    language: AppLanguage
  ) => Promise<ClassLessonsFile>;
  saveLessonsFileForClass: (
    classNumber: ClassNumber,
    language: AppLanguage,
    data: ClassLessonsFile
  ) => Promise<void>;
  loadNavigationState: <T>() => Promise<T | null>;
  saveNavigationState: <T>(data: T) => Promise<void>;
};
