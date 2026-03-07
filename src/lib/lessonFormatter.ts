import {
  ClassNumber,
  FormattedTask,
  LessonTemplate,
  LessonType,
  ExerciseTemplate
} from './types';

function toQuizTask(task: ExerciseTemplate): FormattedTask {
  return {
    id: task.id,
    title: `Question: ${task.prompt}`,
    content: task.choices?.join(' | ') ?? 'No choices provided',
    metadata: {
      answer: task.answer ?? 'N/A',
      hints: task.hints ?? []
    }
  };
}

function toStoryTask(task: ExerciseTemplate): FormattedTask {
  return {
    id: task.id,
    title: `Story step: ${task.prompt}`,
    content: task.narrative ?? task.explanation ?? 'Continue the story.',
    metadata: {
      hints: task.hints ?? []
    }
  };
}

function toFlashcardTask(task: ExerciseTemplate): FormattedTask {
  return {
    id: task.id,
    title: `Card: ${task.prompt}`,
    content: task.answer ?? task.explanation ?? 'Flip for details',
    metadata: {
      hints: task.hints ?? []
    }
  };
}

function resolveExercises(template: LessonTemplate): ExerciseTemplate[] {
  return template.exercises ?? template.exersices ?? [];
}

export function formatTaskByType(task: ExerciseTemplate, type: LessonType): FormattedTask {
  switch (type) {
    case 'quiz':
      return toQuizTask(task);
    case 'story':
      return toStoryTask(task);
    case 'flashcards':
      return toFlashcardTask(task);
    default:
      return {
        id: task.id,
        title: task.prompt,
        content: task.explanation ?? '',
        metadata: {}
      };
  }
}

export function generateLessonFromTemplate(
  template: LessonTemplate,
  type: LessonType,
  timestamp: string,
  classNumber: ClassNumber,
  moduleId: string,
  themeId: string
) {
  return {
    id: `${template.id}-${type}-${Date.now()}`,
    title: `${template.title} (${type})`,
    topic: template.topic,
    type,
    classNumber,
    moduleId,
    themeId,
    createdAt: timestamp,
    tasks: resolveExercises(template).map((task) => formatTaskByType(task, type))
  };
}
