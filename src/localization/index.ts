import { appConfig, AppLanguage } from '../config/appConfig';
import { ExerciseKind } from '../lib/types';

const translations = {
  en: {
    chooseClassWithLessons: 'Choose class with lessons',
    allExercises: 'All exercises',
    back: 'Back',
    backToThemes: 'Back to Themes',
    classLabel: 'Class',
    columns: 'Columns',
    connectChooseFirst: 'Choose an item from the first column',
    connectChooseSecond: 'Now choose the matching item',
    connectCorrectPairs: 'Correct pairs',
    connectResultCorrect: 'Correct',
    connectResultWrong: 'Wrong',
    connectResultsReady: 'All pairs connected',
    competition: 'Competition',
    correctAnswer: 'Correct answer',
    dataToFill: 'Data to fill',
    downloadPdf: 'Download PDF',
    downloadPdfDialog: 'Download lesson PDF',
    exerciseTypeDiagram: 'Diagram',
    exerciseTypeConnect: 'Connect',
    exerciseTypeHomework: 'Homework',
    exerciseTypeInteractiveQuiz: 'Competition',
    exerciseTypeRebus: 'Rebus',
    exerciseTypeTable: 'Table',
    exerciseTypeText: 'Text',
    exerciseTypeVideo: 'Video',
    errorDownloadPdf: 'Could not generate PDF file for this lesson.',
    errorLessonNotFound: 'Lesson not found in current data.',
    errorLoadClass: 'Failed to load class lessons JSON.',
    exerciseCardTitle: 'Flashcard',
    exercises: 'Exercises',
    flashcard: 'Flashcard',
    loading: 'Loading...',
    loadingClassData: 'Loading class data...',
    module: 'Module',
    next: 'Next',
    noExercises: 'No exercises in this lesson.',
    noRowNames: 'No row names',
    noThemes: 'No themes found in class config.',
    oneByOne: 'One by one',
    openLesson: 'Open lesson',
    openYoutubeVideo: 'Open YouTube Video',
    prev: 'Prev',
    quiz: 'Quiz',
    rows: 'Rows',
    seeAllExercises: 'See all exercises',
    story: 'Story',
    theme: 'Theme',
    themes: 'Themes',
    topic: 'Topic',
    type: 'Type',
    watchYoutubeVideo: 'Open YouTube video',
    yourChoice: 'Your choice'
  },
  ua: {
    chooseClassWithLessons: 'Оберіть клас з уроками',
    allExercises: 'Усі вправи',
    back: 'Назад',
    backToThemes: 'Назад до тем',
    classLabel: 'Клас',
    columns: 'Колонки',
    connectChooseFirst: 'Оберіть елемент з першої колонки',
    connectChooseSecond: 'Тепер оберіть відповідний елемент',
    connectCorrectPairs: 'Правильні пари',
    connectResultCorrect: 'Правильно',
    connectResultWrong: 'Неправильно',
    connectResultsReady: 'Усі пари з’єднано',
    competition: 'Змагання',
    correctAnswer: 'Правильна відповідь',
    dataToFill: 'Дані для заповнення',
    downloadPdf: 'Завантажити PDF',
    downloadPdfDialog: 'Завантажити PDF уроку',
    exerciseTypeDiagram: 'Діаграма',
    exerciseTypeConnect: 'З`єднання',
    exerciseTypeHomework: 'Домашнє завдання',
    exerciseTypeInteractiveQuiz: 'Змагання',
    exerciseTypeRebus: 'Ребус',
    exerciseTypeTable: 'Таблиця',
    exerciseTypeText: 'Текст',
    exerciseTypeVideo: 'Відео',
    errorDownloadPdf: 'Не вдалося створити PDF для цього уроку.',
    errorLessonNotFound: 'Урок не знайдено в поточних даних.',
    errorLoadClass: 'Не вдалося завантажити JSON дані класу.',
    exerciseCardTitle: 'Картка',
    exercises: 'Вправи',
    flashcard: 'Картка',
    loading: 'Завантаження...',
    loadingClassData: 'Завантаження даних класу...',
    module: 'Модуль',
    next: 'Далі',
    noExercises: 'У цьому уроці немає вправ.',
    noRowNames: 'Без назв рядків',
    noThemes: 'У конфігурації класу не знайдено тем.',
    oneByOne: 'По одній',
    openLesson: 'Відкрити урок',
    openYoutubeVideo: 'Відкрити відео YouTube',
    prev: 'Назад',
    quiz: 'Тест',
    rows: 'Рядки',
    seeAllExercises: 'Показати всі вправи',
    story: 'Історія',
    theme: 'Тема',
    themes: 'Теми',
    topic: 'Тема уроку',
    type: 'Тип',
    watchYoutubeVideo: 'Відкрити відео YouTube',
    yourChoice: 'Ваш вибір'
  }
} as const;

type TranslationKey = keyof (typeof translations)['en'];

export function tr(key: TranslationKey, language: AppLanguage = appConfig.currentLanguage) {
  return translations[language][key];
}

export function formatTypeLabel(type: 'all' | 'quiz' | 'story' | 'competition') {
  if (type === 'all') {
    return `${tr('seeAllExercises')}`;
  }
  if (type === 'competition') {
    return tr('competition');
  }
  if (type === 'quiz') {
    return tr('quiz');
  }
  return tr('story');
}

export function formatExerciseTypeLabel(type: ExerciseKind) {
  switch (type) {
    case 'diagram':
      return tr('exerciseTypeDiagram');
    case 'connect':
      return tr('exerciseTypeConnect');
    case 'table':
      return tr('exerciseTypeTable');
    case 'text':
      return tr('exerciseTypeText');
    case 'rebus':
      return tr('exerciseTypeRebus');
    case 'video':
      return tr('exerciseTypeVideo');
    case 'interactive_quiz':
      return tr('exerciseTypeInteractiveQuiz');
    case 'homework':
      return tr('exerciseTypeHomework');
    default:
      return type;
  }
}
