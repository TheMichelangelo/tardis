export type LessonType = 'quiz' | 'story' | 'flashcards';
export type ClassNumber = 5 | 6;

export type ExerciseTemplate = {
  id: string;
  prompt: string;
  hints?: string[];
  choices?: string[];
  answer?: string;
  explanation?: string;
  narrative?: string;
};

export type LessonTemplate = {
  id: string;
  title: string;
  topic: string;
  formats: LessonType[];
  exercises?: ExerciseTemplate[];
  exersices?: ExerciseTemplate[];
};

export type Theme = {
  id: string;
  title: string;
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
