export type LessonType = 'quiz' | 'story' | 'competition';
export type LessonFormat = LessonType | 'flashcards';
export type ExerciseFormat = LessonType | 'flashcards' | 'all';
export type ClassNumber = 5 | 6;

export type ExerciseKind =
  | 'diagram'
  | 'table'
  | 'text'
  | 'rebus'
  | 'video'
  | 'interactive_quiz'
  | 'homework'
  | 'connect';

export type ExerciseBase = {
  id: string;
  label: string;
  type: ExerciseKind;
  formats?: ExerciseFormat[];
};

export type DiagramExercise = ExerciseBase & {
  type: 'diagram';
  imageExt?: 'png' | 'jpg' | 'jpeg';
};

export type RebusExercise = ExerciseBase & {
  type: 'rebus';
  imageExt?: 'png' | 'jpg' | 'jpeg';
};

export type TableExercise = ExerciseBase & {
  type: 'table';
  columns: string[];
  rows?: string[];
  dataToFill: string[];
};

export type TextExercise = ExerciseBase & {
  type: 'text';
  text: string;
  questions?: string[];
};

export type VideoExercise = ExerciseBase & {
  type: 'video';
  youtubeUrl: string;
  questions?: string[];
};

export type InteractiveQuizQuestion = {
  id: string;
  question: string;
  answerTypes: {
    singleChoice: string[];
    trueFalse: 'True' | 'False';
    shortText: string;
  };
};

export type InteractiveQuizExercise = ExerciseBase & {
  type: 'interactive_quiz';
  questions: InteractiveQuizQuestion[];
};

export type HomeworkExercise = ExerciseBase & {
  type: 'homework';
  text: string;
  imageExt?: 'png' | 'jpg' | 'jpeg';
  videoUrl?: string;
};

export type ConnectExercise = ExerciseBase & {
  type: 'connect';
  text: string;
  column1Items: string[];
  column2Items: string[];
  display: 'horizontal' | 'vertical';
};

export type LessonExercise =
  | DiagramExercise
  | RebusExercise
  | TableExercise
  | TextExercise
  | VideoExercise
  | InteractiveQuizExercise
  | HomeworkExercise
  | ConnectExercise;

export type LessonTemplate = {
  id: string;
  title: string;
  topic: string;
  formats: LessonFormat[];
  exercises?: LessonExercise[];
  exersices?: LessonExercise[];
};

export type Theme = {
  id: string;
  color: string;
  lessons: LessonTemplate[];
};

export type Module = {
  id: string;
  title: string;
  themes: Theme[];
};

export type FormattedTask = {
  id: string;
  title: string;
  content: string;
  metadata?: Record<string, string | string[]>;
};

export type GeneratedLesson = {
  id: string;
  title: string;
  topic: string;
  type: LessonType;
  classNumber: ClassNumber;
  moduleId: string;
  themeId: string;
  createdAt: string;
  tasks: FormattedTask[];
};

export type ClassLessonsFile = {
  modules: Module[];
  lessons: GeneratedLesson[];
};

export type StoredUser = {
  id: string;
  emailHash: string;
  passwordHash: string;
  placeOfWork: string;
};

export type UserRecordFile = {
  users: StoredUser[];
};

export type AuthUser = {
  id: string;
  placeOfWork: string;
};
