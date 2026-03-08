# STEM Lesson Builder

[English version](./README_EN.md)

React Native застосунок з пріоритетом для формування уроків STEM 5х і 6х класів.

## Конфігурація мов

- Поточна мова інтерфейсу/даних налаштовується у:
  - `src/config/appConfig.ts` (`currentLanguage: 'en' | 'ua'`)
- Локалізовані підписи зберігаються у:
  - `src/localization/index.ts`

## Модель вправ уроку

Кожен урок містить набір вправ - `exercises` (або `exersices` для сумісності).

Поля вправи:

- `id`: номер вправи
- `label`: опис завадння
- `formats?`: необов’язковий список форматів, для яких підходить вправа (`quiz`, `story`, `competition`, `all`)
- `type`: один із типів вправи:
  - `diagram` (шлях до зображення `src/data/<lesson-id>/<exercise-id>.<ext>`)
  - `table` (`columns`, необов’язкові `rows`, `dataToFill`)
  - `text` (`text`, необов’язкові `questions`)
  - `rebus` (шлях до зображення `src/data/<lesson-id>/<exercise-id>.<ext>`)
  - `video` (`youtubeUrl`, необов’язкові `questions`)
  - `interactive_quiz` (`questions[]` з типами `singleChoice`, `trueFalse`, `shortText`)
  - `homework` (`text`, необов’язкові `imageExt`, необов’язковий `videoUrl`; зображення: `src/data/<lesson-id>/<exercise-id>.<ext>`)

`homework`- домашнє завдання, завжди відображається незалежно від вибраного формату.

## Приклади типів вправ

```json
{
  "id": "diagram-1",
  "label": "Познач частини схеми",
  "type": "diagram",
  "imageExt": "png"
}
```

```json
{
  "id": "table-1",
  "label": "Заповни таблицю",
  "type": "table",
  "columns": ["Параметр", "Значення"],
  "rows": ["Рядок 1", "Рядок 2"],
  "dataToFill": ["Маса", "12 кг", "Сила", "5 Н"]
}
```

```json
{
  "id": "text-1",
  "label": "Прочитай текст і дай відповіді",
  "type": "text",
  "text": "Світло поширюється прямолінійно в однорідному середовищі.",
  "questions": ["Що таке однорідне середовище?", "Наведи приклад."]
}
```

```json
{
  "id": "rebus-1",
  "label": "Розгадай ребус",
  "type": "rebus",
  "imageExt": "jpg"
}
```

```json
{
  "id": "video-1",
  "label": "Переглянь відео",
  "type": "video",
  "youtubeUrl": "https://www.youtube.com/watch?v=VAgt2vo9HdE",
  "questions": ["Яку головну ідею ти побачив?", "Який приклад запам'ятався?"]
}
```

```json
{
  "id": "quiz-1",
  "label": "Мінікартки",
  "type": "interactive_quiz",
  "questions": [
    {
      "id": "q1",
      "question": "Яка одиниця сили?",
      "answerTypes": {
        "singleChoice": ["Ньютон", "Ват", "Паскаль"],
        "trueFalse": "True",
        "shortText": "Ньютон"
      }
    }
  ]
}
```

```json
{
  "id": "homework-1",
  "label": "Домашнє завдання",
  "type": "homework",
  "text": "Підготуй приклад застосування сили тертя в побуті.",
  "imageExt": "png",
  "videoUrl": "https://www.youtube.com/watch?v=VAgt2vo9HdE"
}
```

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

## Demo - Web Version

### Головна сторінка
![Головна сторінка додатку](./demo/main_page.png)
Основний інтерфейс для вибору класу та налаштувань уроку.

### Вибір класу з темами
![Інтерфейс вибору класу з доступними темами](./demo/class_with_themes_examle.png)
Сторінка вибору класу з відображенням доступних навчальних тем.

### Деталі теми уроку
![Розширений вигляд тем з деталями](./demo/class_with_themes_examle_2.png)
Детальний перегляд обраної теми з описом та вправами.

### Приклад уроку
![Інтерфейс виконання уроку](./demo/lesson_demo.png)
Робочий інтерфейс уроку з різними типами вправ.

### Версія для друку
![Приклад версії вправи для друку](./demo/print_exersice_version.png)
Оптимізована версія для друку навчальних матеріалів.
