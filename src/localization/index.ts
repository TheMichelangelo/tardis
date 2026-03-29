import { appConfig, AppLanguage } from '../config/appConfig';
import { ExerciseKind } from '../lib/types';

const translations = {
  en: {
    chooseClassWithLessons: 'Choose class with lessons',
    allExercises: 'All exercises',
    back: 'Back',
    backToThemes: 'Back to Themes',
    classLabel: 'Class',
    columnOne: 'Column 1',
    columnTwo: 'Column 2',
    columns: 'Columns',
    connectDisplayHorizontal: 'Horizontal',
    connectDisplayVertical: 'Vertical',
    connectChooseFirst: 'Choose an item from the first column',
    connectChooseSecond: 'Now choose the matching item',
    connectCorrectPairs: 'Correct pairs',
    connectResultCorrect: 'Correct',
    connectResultWrong: 'Wrong',
    connectResultsReady: 'All pairs connected',
    competition: 'Competition',
    createProposal: 'Propose lesson or exercise',
    exerciseProposal: 'Exercise proposal',
    correctAnswer: 'Correct answer',
    dataToFill: 'Data to fill',
    displayMode: 'Display mode',
    downloadPdf: 'Download PDF',
    downloadPdfDialog: 'Download lesson PDF',
    exerciseLabel: 'Exercise label',
    exerciseId: 'Exercise id',
    exerciseType: 'Exercise type',
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
    imageUpload: 'Upload image',
    imageUploadHint: 'Image upload is available in the web version.',
    invalidLoginCredentials: 'Incorrect email or password.',
    email: 'Email',
    emailPlaceholder: 'Enter your email',
    lessonId: 'Lesson id',
    lessonProposal: 'Lesson proposal',
    lessonTitle: 'Lesson title',
    listItemsHint: 'One item per line',
    loading: 'Loading...',
    loadingClassData: 'Loading class data...',
    login: 'Log in',
    loginHint: 'Use the credentials provided by the administrator.',
    logout: 'Log out',
    moduleId: 'Module',
    module: 'Module',
    newExercise: 'New exercise',
    newLesson: 'New lesson',
    next: 'Next',
    noExercises: 'No exercises in this lesson.',
    noRowNames: 'No row names',
    noThemes: 'No themes found in class config.',
    oneByOne: 'One by one',
    openLesson: 'Open lesson',
    openYoutubeVideo: 'Open YouTube Video',
    previewJson: 'Proposal JSON',
    prev: 'Prev',
    proposalSaved: 'Proposal prepared below.',
    proposalType: 'Proposal type',
    password: 'Password',
    passwordPlaceholder: 'Enter your password',
    questions: 'Questions',
    quiz: 'Quiz',
    rowNamesOptional: 'Row names (optional)',
    rows: 'Rows',
    selectLesson: 'Select lesson',
    selectTheme: 'Select theme',
    seeAllExercises: 'See all exercises',
    singleChoiceOptions: 'Single choice options',
    story: 'Story',
    submitProposal: 'Create proposal',
    theme: 'Theme',
    themes: 'Themes',
    textContent: 'Text',
    topic: 'Topic',
    type: 'Type',
    uploadSelectedImage: 'Selected image',
    watchYoutubeVideo: 'Open YouTube video',
    youtubeUrl: 'YouTube URL',
    yourChoice: 'Your choice'
  },
  ua: {
    chooseClassWithLessons: 'Оберіть клас з уроками',
    allExercises: 'Усі вправи',
    back: 'Назад',
    backToThemes: 'Назад до тем',
    classLabel: 'Клас',
    columnOne: 'Колонка 1',
    columnTwo: 'Колонка 2',
    columns: 'Колонки',
    connectDisplayHorizontal: 'Горизонтально',
    connectDisplayVertical: 'Вертикально',
    connectChooseFirst: 'Оберіть елемент з першої колонки',
    connectChooseSecond: 'Тепер оберіть відповідний елемент',
    connectCorrectPairs: 'Правильні пари',
    connectResultCorrect: 'Правильно',
    connectResultWrong: 'Неправильно',
    connectResultsReady: 'Усі пари з’єднано',
    competition: 'Змагання',
    createProposal: 'Запропонувати урок або вправу',
    exerciseProposal: 'Пропозиція вправи',
    correctAnswer: 'Правильна відповідь',
    dataToFill: 'Дані для заповнення',
    displayMode: 'Режим відображення',
    downloadPdf: 'Завантажити PDF',
    downloadPdfDialog: 'Завантажити PDF уроку',
    exerciseLabel: 'Назва вправи',
    exerciseId: 'Id вправи',
    exerciseType: 'Тип вправи',
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
    imageUpload: 'Завантажити зображення',
    imageUploadHint: 'Завантаження зображень доступне у веб-версії.',
    invalidLoginCredentials: 'Неправильний email або пароль.',
    email: 'Email',
    emailPlaceholder: 'Введіть email',
    lessonId: 'Id уроку',
    lessonProposal: 'Пропозиція уроку',
    lessonTitle: 'Назва уроку',
    listItemsHint: 'Один елемент на рядок',
    loading: 'Завантаження...',
    loadingClassData: 'Завантаження даних класу...',
    login: 'Увійти',
    loginHint: 'Використайте облікові дані, надані адміністратором.',
    logout: 'Вийти',
    moduleId: 'Модуль',
    module: 'Модуль',
    newExercise: 'Нова вправа',
    newLesson: 'Новий урок',
    next: 'Далі',
    noExercises: 'У цьому уроці немає вправ.',
    noRowNames: 'Без назв рядків',
    noThemes: 'У конфігурації класу не знайдено тем.',
    oneByOne: 'По одній',
    openLesson: 'Відкрити урок',
    openYoutubeVideo: 'Відкрити відео YouTube',
    previewJson: 'JSON пропозиції',
    prev: 'Назад',
    proposalSaved: 'Пропозицію підготовлено нижче.',
    proposalType: 'Тип пропозиції',
    password: 'Пароль',
    passwordPlaceholder: 'Введіть пароль',
    questions: 'Питання',
    quiz: 'Тест',
    rowNamesOptional: 'Назви рядків (необов`язково)',
    rows: 'Рядки',
    selectLesson: 'Оберіть урок',
    selectTheme: 'Оберіть тему',
    seeAllExercises: 'Показати всі вправи',
    singleChoiceOptions: 'Варіанти відповіді',
    story: 'Історія',
    submitProposal: 'Створити пропозицію',
    theme: 'Тема',
    themes: 'Теми',
    textContent: 'Текст',
    topic: 'Тема уроку',
    type: 'Тип',
    uploadSelectedImage: 'Вибране зображення',
    watchYoutubeVideo: 'Відкрити відео YouTube',
    youtubeUrl: 'YouTube URL',
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
