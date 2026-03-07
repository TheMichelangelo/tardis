# STEM Lesson Builder

React Native (Expo) app targeting web first and Android.

## Main flow

- Home page uses white base and displays `src/data/stem_logo.jpeg`.
- Home page has colorful round class buttons: `5` and `6`.
- Opening a class shows theme tabs (each tab has its own color).
- Each theme tab shows lessons and available lesson formats.

## Lesson exercise model

Each lesson now has its own `exercises` list (or `exersices` for compatibility).

Exercise fields:

- `id`: string
- `label`: instruction text
- `type`: one of
  - `diagram` (image path uses `<lesson-id>/<exercise-id>`)
  - `table` (`columns`, optional `rows`, `dataToFill`)
  - `text` (`text`, optional `questions`)
  - `rebus` (image path uses `<lesson-id>/<exercise-id>`)
  - `video` (`youtubeUrl`)
  - `interactive_quiz` (`questions[]` with `singleChoice`, `trueFalse`, `shortText` answer types)

`interactive_quiz` questions are generated as one-by-one flashcard tasks.

## Data configs

- `src/data/5_class_stem_lessons.json`
- `src/data/6_class_stem_lessons.json`

## Storage behavior

- Web: class-specific `localStorage` keys.
- Android/iOS: class-specific JSON files in Expo document directory.
- When loading, app always uses latest module/theme config from JSON files and keeps saved generated lessons.

## Run

```bash
npm install
npm run web
```

For Android:

```bash
npm run android
```
