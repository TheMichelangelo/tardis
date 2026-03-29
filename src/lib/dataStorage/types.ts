import { AppLanguage } from '../../config/appConfig';
import { AuthUser, ClassLessonsFile, ClassNumber } from '../types';

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
  authenticateUser: (email: string, password: string) => Promise<AuthUser | null>;
  loadAuthSession: () => Promise<AuthUser | null>;
  saveAuthSession: (user: AuthUser | null) => Promise<void>;
};
