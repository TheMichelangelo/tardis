import {
  ClassNumber,
  FormattedTask,
  LessonExercise,
  LessonTemplate,
  LessonType
} from './types';

function resolveExercises(template: LessonTemplate): LessonExercise[] {
  return template.exercises ?? template.exersices ?? [];
}

function baseImagePath(lessonId: string, exerciseId: string) {
  return `${lessonId}/${exerciseId}`;
}

function toExerciseTasks(
  lessonId: string,
  exercise: LessonExercise,
  lessonType: LessonType
): FormattedTask[] {
  switch (exercise.type) {
    case 'diagram':
      return [
        {
          id: exercise.id,
          title: `Diagram: ${exercise.label}`,
          content: `Open diagram image: ${baseImagePath(lessonId, exercise.id)}`,
          metadata: {
            lessonType,
            exerciseType: 'diagram',
            imagePath: baseImagePath(lessonId, exercise.id)
          }
        }
      ];

    case 'rebus':
      return [
        {
          id: exercise.id,
          title: `Rebus: ${exercise.label}`,
          content: `Solve rebus image: ${baseImagePath(lessonId, exercise.id)}`,
          metadata: {
            lessonType,
            exerciseType: 'rebus',
            imagePath: baseImagePath(lessonId, exercise.id)
          }
        }
      ];

    case 'table': {
      const rows = exercise.rows && exercise.rows.length > 0 ? exercise.rows.join(', ') : 'no row headers';
      return [
        {
          id: exercise.id,
          title: `Table: ${exercise.label}`,
          content: `Columns: ${exercise.columns.join(', ')} | Rows: ${rows}`,
          metadata: {
            lessonType,
            exerciseType: 'table',
            columns: exercise.columns,
            rows: exercise.rows ?? [],
            dataToFill: exercise.dataToFill
          }
        }
      ];
    }

    case 'text':
      return [
        {
          id: exercise.id,
          title: `Read & Note: ${exercise.label}`,
          content: exercise.text,
          metadata: {
            lessonType,
            exerciseType: 'text',
            questions: exercise.questions ?? []
          }
        }
      ];

    case 'video':
      return [
        {
          id: exercise.id,
          title: `Watch Video: ${exercise.label}`,
          content: exercise.youtubeUrl,
          metadata: {
            lessonType,
            exerciseType: 'video',
            youtubeUrl: exercise.youtubeUrl
          }
        }
      ];

    case 'interactive_quiz':
      return exercise.questions.map((q, index) => ({
        id: `${exercise.id}-${q.id}`,
        title: `Flashcard ${index + 1}: ${q.question}`,
        content: [
          `Single choice: ${q.answerTypes.singleChoice.join(' | ')}`,
          `True/False: ${q.answerTypes.trueFalse}`,
          `Short text: ${q.answerTypes.shortText}`
        ].join('\n'),
        metadata: {
          lessonType,
          exerciseType: 'interactive_quiz'
        }
      }));

    case 'homework':
      return [
        {
          id: exercise.id,
          title: `Homework: ${exercise.label}`,
          content: exercise.text,
          metadata: {
            lessonType,
            exerciseType: 'homework',
            videoUrl: exercise.videoUrl ?? ''
          }
        }
      ];

    case 'connect':
      return [
        {
          id: exercise.id,
          title: `Connect: ${exercise.label}`,
          content: exercise.text,
          metadata: {
            lessonType,
            exerciseType: 'connect',
            column1Items: exercise.column1Items,
            column2Items: exercise.column2Items,
            display: exercise.display
          }
        }
      ];

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
  const tasks = resolveExercises(template).flatMap((exercise) =>
    toExerciseTasks(template.id, exercise, type)
  );

  return {
    id: `${template.id}-${type}-${Date.now()}`,
    title: `${template.title} (${type})`,
    topic: template.topic,
    type,
    classNumber,
    moduleId,
    themeId,
    createdAt: timestamp,
    tasks
  };
}
