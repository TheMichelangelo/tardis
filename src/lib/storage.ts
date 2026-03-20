import * as FileSystem from 'expo-file-system';
import class5LessonsEn from '../data/5_class_stem_lesson_en.json';
import class6LessonsEn from '../data/6_class_stem_lesson_en.json';
import class5LessonsUa from '../data/5_class_stem_lesson_ua.json';
import class6LessonsUa from '../data/6_class_stem_lesson_ua.json';
import { AppLanguage } from '../config/appConfig';
import { ClassLessonsFile, ClassNumber } from './types';

const STORAGE_KEY_PREFIX = 'lesson_builder_data_v4_class_';
const APP_NAVIGATION_STORAGE_KEY = 'lesson_builder_navigation_v1';
type WebStorage = {
  getItem: (key: string) => string | null;
  setItem: (key: string, value: string) => void;
};

const classDefaults: Record<AppLanguage, Record<ClassNumber, ClassLessonsFile>> = {
  en: {
    5: class5LessonsEn as ClassLessonsFile,
    6: class6LessonsEn as ClassLessonsFile
  },
  ua: {
    5: class5LessonsUa as ClassLessonsFile,
    6: class6LessonsUa as ClassLessonsFile
  }
};

function mergeWithLatestConfig(defaults: ClassLessonsFile, stored: ClassLessonsFile | null): ClassLessonsFile {
  return {
    modules: defaults.modules,
    lessons: stored?.lessons ?? []
  };
}

function isWeb() {
  return typeof window !== 'undefined';
}

function getWebStorage() {
  return (globalThis as { localStorage?: WebStorage }).localStorage;
}

function getStorageKey(classNumber: ClassNumber, language: AppLanguage) {
  return `${STORAGE_KEY_PREFIX}${classNumber}_${language}`;
}

async function getFilePath(classNumber: ClassNumber, language: AppLanguage) {
  return `${FileSystem.documentDirectory}${classNumber}_class_stem_lesson_${language}.json`;
}

async function getNavigationStateFilePath() {
  return `${FileSystem.documentDirectory}${APP_NAVIGATION_STORAGE_KEY}.json`;
}

async function readNativeFile(classNumber: ClassNumber, language: AppLanguage): Promise<ClassLessonsFile | null> {
  const path = await getFilePath(classNumber, language);
  const info = await FileSystem.getInfoAsync(path);

  if (!info.exists) {
    return null;
  }

  const raw = await FileSystem.readAsStringAsync(path);
  return JSON.parse(raw) as ClassLessonsFile;
}

async function writeNativeFile(classNumber: ClassNumber, language: AppLanguage, data: ClassLessonsFile) {
  const path = await getFilePath(classNumber, language);
  await FileSystem.writeAsStringAsync(path, JSON.stringify(data, null, 2));
}

async function readNativeNavigationState<T>(): Promise<T | null> {
  const path = await getNavigationStateFilePath();
  const info = await FileSystem.getInfoAsync(path);

  if (!info.exists) {
    return null;
  }

  const raw = await FileSystem.readAsStringAsync(path);
  return JSON.parse(raw) as T;
}

async function writeNativeNavigationState<T>(data: T) {
  const path = await getNavigationStateFilePath();
  await FileSystem.writeAsStringAsync(path, JSON.stringify(data, null, 2));
}

function readWebStorage(classNumber: ClassNumber, language: AppLanguage): ClassLessonsFile | null {
  const storage = getWebStorage();
  if (!storage) {
    return null;
  }

  const raw = storage.getItem(getStorageKey(classNumber, language));
  if (!raw) {
    return null;
  }

  return JSON.parse(raw) as ClassLessonsFile;
}

function writeWebStorage(classNumber: ClassNumber, language: AppLanguage, data: ClassLessonsFile) {
  const storage = getWebStorage();
  if (!storage) {
    return;
  }

  storage.setItem(getStorageKey(classNumber, language), JSON.stringify(data));
}

function readWebNavigationState<T>(): T | null {
  const storage = getWebStorage();
  if (!storage) {
    return null;
  }

  const raw = storage.getItem(APP_NAVIGATION_STORAGE_KEY);
  if (!raw) {
    return null;
  }

  return JSON.parse(raw) as T;
}

function writeWebNavigationState<T>(data: T) {
  const storage = getWebStorage();
  if (!storage) {
    return;
  }

  storage.setItem(APP_NAVIGATION_STORAGE_KEY, JSON.stringify(data));
}

export async function loadLessonsFileForClass(
  classNumber: ClassNumber,
  language: AppLanguage
): Promise<ClassLessonsFile> {
  const defaults = classDefaults[language][classNumber];

  if (isWeb()) {
    const stored = readWebStorage(classNumber, language);
    if (stored) {
      const merged = mergeWithLatestConfig(defaults, stored);
      writeWebStorage(classNumber, language, merged);
      return merged;
    }

    writeWebStorage(classNumber, language, defaults);
    return defaults;
  }

  const native = await readNativeFile(classNumber, language);
  if (native) {
    const merged = mergeWithLatestConfig(defaults, native);
    await writeNativeFile(classNumber, language, merged);
    return merged;
  }

  await writeNativeFile(classNumber, language, defaults);
  return defaults;
}

export async function saveLessonsFileForClass(
  classNumber: ClassNumber,
  language: AppLanguage,
  data: ClassLessonsFile
) {
  if (isWeb()) {
    writeWebStorage(classNumber, language, data);
    return;
  }

  await writeNativeFile(classNumber, language, data);
}

export async function loadNavigationState<T>(): Promise<T | null> {
  if (isWeb()) {
    return readWebNavigationState<T>();
  }

  return readNativeNavigationState<T>();
}

export async function saveNavigationState<T>(data: T) {
  if (isWeb()) {
    writeWebNavigationState(data);
    return;
  }

  await writeNativeNavigationState(data);
}
