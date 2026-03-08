# STEM Lesson Builder

[English version](./README_EN.md)

React Native (Expo) застосунок з пріоритетом для вебу та можливістю запуску на Android.

## Основний сценарій

- Головна сторінка має білий фон і показує `src/data/stem_logo.jpeg`.
- На головній сторінці є кольорові круглі кнопки класів: `5` і `6`.
- Після відкриття класу відображаються вкладки тем (кожна тема має свій колір).
- У кожній вкладці теми показуються уроки та доступні формати уроків.

## Конфігурація мов

- Поточна мова інтерфейсу/даних налаштовується у:
  - `src/config/appConfig.ts` (`currentLanguage: 'en' | 'ua'`)
- Локалізовані підписи зберігаються у:
  - `src/localization/index.ts`

## Модель вправ уроку

Кожен урок містить `exercises` (або `exersices` для сумісності).

Поля вправи:

- `id`: рядок
- `label`: текст інструкції
- `formats?`: необов’язковий список форматів (`quiz`, `story`, `competition`, `all`)
- `type`: один із типів:
  - `diagram` (шлях до зображення `<lesson-id>/<exercise-id>.<ext>`)
  - `table` (`columns`, необов’язкові `rows`, `dataToFill`)
  - `text` (`text`, необов’язкові `questions`)
  - `rebus` (шлях до зображення `<lesson-id>/<exercise-id>.<ext>`)
  - `video` (`youtubeUrl`, необов’язкові `questions`)
  - `interactive_quiz` (`questions[]` з типами `singleChoice`, `trueFalse`, `shortText`)
  - `homework` (`text`, необов’язкові `imageExt`, необов’язковий `videoUrl`)

`homework` завжди відображається незалежно від вибраного формату.

## Конфіги даних

Мовозалежні файли класів:

- `src/data/5_class_stem_lesson_en.json`
- `src/data/6_class_stem_lesson_en.json`
- `src/data/5_class_stem_lesson_ua.json`
- `src/data/6_class_stem_lesson_ua.json`

## Зберігання даних

- Веб: `localStorage` ключі з прив’язкою до класу та мови.
- Android/iOS: JSON-файли з прив’язкою до класу та мови в директорії документів Expo.
- Під час завантаження застосунок бере актуальну конфігурацію модулів/тем із мовних JSON-файлів і зберігає згенеровані уроки користувача.

## Запуск

```bash
npm install
npm run web
```

Для Android:

```bash
npm run android
```
