import * as FileSystem from 'expo-file-system';
import class5Lessons from '../data/5_class_stem_lessons.json';
import class6Lessons from '../data/6_class_stem_lessons.json';
import { ClassLessonsFile, ClassNumber } from './types';

const STORAGE_KEY_PREFIX = 'lesson_builder_data_v3_class_';
type WebStorage = {
  getItem: (key: string) => string | null;
  setItem: (key: string, value: string) => void;
};

const classDefaults: Record<ClassNumber, ClassLessonsFile> = {
  5: class5Lessons as ClassLessonsFile,
  6: class6Lessons as ClassLessonsFile
};

function mergeWithLatestConfig(
  defaults: ClassLessonsFile,
  stored: ClassLessonsFile | null
): ClassLessonsFile {
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

function getStorageKey(classNumber: ClassNumber) {
  return `${STORAGE_KEY_PREFIX}${classNumber}`;
}

async function getFilePath(classNumber: ClassNumber) {
  return `${FileSystem.documentDirectory}${classNumber}_class_stem_lessons.json`;
}

async function readNativeFile(classNumber: ClassNumber): Promise<ClassLessonsFile | null> {
  const path = await getFilePath(classNumber);
  const info = await FileSystem.getInfoAsync(path);

  if (!info.exists) {
    return null;
  }

  const raw = await FileSystem.readAsStringAsync(path);
  return JSON.parse(raw) as ClassLessonsFile;
}

async function writeNativeFile(classNumber: ClassNumber, data: ClassLessonsFile) {
  const path = await getFilePath(classNumber);
  await FileSystem.writeAsStringAsync(path, JSON.stringify(data, null, 2));
}

function readWebStorage(classNumber: ClassNumber): ClassLessonsFile | null {
  const storage = getWebStorage();
  if (!storage) {
    return null;
  }

  const raw = storage.getItem(getStorageKey(classNumber));
  if (!raw) {
    return null;
  }

  return JSON.parse(raw) as ClassLessonsFile;
}

function writeWebStorage(classNumber: ClassNumber, data: ClassLessonsFile) {
  const storage = getWebStorage();
  if (!storage) {
    return;
  }

  storage.setItem(getStorageKey(classNumber), JSON.stringify(data));
}

export async function loadLessonsFileForClass(classNumber: ClassNumber): Promise<ClassLessonsFile> {
  const defaults = classDefaults[classNumber];

  if (isWeb()) {
    const stored = readWebStorage(classNumber);
    if (stored) {
      const merged = mergeWithLatestConfig(defaults, stored);
      writeWebStorage(classNumber, merged);
      return merged;
    }

    writeWebStorage(classNumber, defaults);
    return defaults;
  }

  const native = await readNativeFile(classNumber);
  if (native) {
    const merged = mergeWithLatestConfig(defaults, native);
    await writeNativeFile(classNumber, merged);
    return merged;
  }

  await writeNativeFile(classNumber, defaults);
  return defaults;
}

export async function saveLessonsFileForClass(classNumber: ClassNumber, data: ClassLessonsFile) {
  if (isWeb()) {
    writeWebStorage(classNumber, data);
    return;
  }

  await writeNativeFile(classNumber, data);
}
