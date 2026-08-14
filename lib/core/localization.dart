import '../models.dart';

abstract final class AppStrings {
  static const _uk = <String, String>{
    'choose': 'Оберіть клас з уроками',
    'class': 'Клас',
    'module': 'Модуль',
    'topic': 'Тема уроку',
    'exercises': 'Вправи',
    'open': 'Відкрити урок',
    'all': 'Усі вправи',
    'none': 'У цьому уроці немає вправ.',
    'quiz': 'Тест',
    'story': 'Історія',
    'competition': 'Змагання',
    'flashcards': 'Картки',
    'diagram': 'Діаграма',
    'rebus': 'Ребус',
    'table': 'Таблиця',
    'text': 'Текст',
    'video': 'Відео',
    'interactiveQuiz': 'Змагання',
    'homework': 'Домашнє завдання',
    'connect': 'З’єднання',
    'watch': 'Відкрити відео',
    'answer': 'Ваша відповідь',
    'loadError': 'Не вдалося завантажити матеріали класу.',
    'noThemes': 'Для цього класу ще немає тем.',
    'login': 'Увійти',
    'logout': 'Вийти',
    'email': 'Email',
    'emailHint': 'Введіть email',
    'password': 'Пароль',
    'passwordHint': 'Введіть пароль',
    'loginHelp': 'Використайте дані, надані адміністратором.',
    'invalidCredentials': 'Неправильний email або пароль.',
    'loading': 'Завантаження…',
    'downloadAndroid': 'Завантажити Android APK',
    'downloadError': 'Не вдалося відкрити файл APK.',
  };

  static String get(String key) => _uk[key] ?? key;

  static String format(LessonFormat format) => get(format.jsonValue);

  static String exerciseType(ExerciseType type) => get(type.name);
}
