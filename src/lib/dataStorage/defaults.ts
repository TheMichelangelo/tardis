import class5LessonsEn from '../../data/5_class_stem_lesson_en.json';
import class6LessonsEn from '../../data/6_class_stem_lesson_en.json';
import class5LessonsUa from '../../data/5_class_stem_lesson_ua.json';
import class6LessonsUa from '../../data/6_class_stem_lesson_ua.json';
import { AppLanguage } from '../../config/appConfig';
import { ClassLessonsFile, ClassNumber } from '../types';

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

export function getDefaultLessonsFile(
  classNumber: ClassNumber,
  language: AppLanguage
): ClassLessonsFile {
  return classDefaults[language][classNumber];
}

export function mergeWithLatestConfig(
  defaults: ClassLessonsFile,
  stored: ClassLessonsFile | null
): ClassLessonsFile {
  return {
    modules: defaults.modules,
    lessons: stored?.lessons ?? []
  };
}
