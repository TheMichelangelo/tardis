# STEM Lesson Builder

React Native (Expo) app targeting web first and Android.

## Main flow

- Home page uses white base and displays `src/data/stem_logo.jpeg`.
- Home page has colorful round class buttons: `5` and `6`.
- Opening a class shows theme tabs (each tab has its own color).
- Each theme tab shows lessons and available lesson formats.

## Language config

- Current UI/data language is configured in:
  - `src/config/appConfig.ts` (`currentLanguage: 'en' | 'ua'`)
- Localized labels are stored in:
  - `src/localization/index.ts`

## Lesson exercise model

Each lesson has `exercises` (or `exersices` for compatibility).

Exercise fields:

- `id`: string
- `label`: instruction text
- `formats?`: optional list of formats (`quiz`, `story`, `competition`, `all`)
- `type`: one of
  - `diagram` (image path `<lesson-id>/<exercise-id>.<ext>`)
  - `table` (`columns`, optional `rows`, `dataToFill`)
  - `text` (`text`, optional `questions`)
  - `rebus` (image path `<lesson-id>/<exercise-id>.<ext>`)
  - `video` (`youtubeUrl`, optional `questions`)
  - `interactive_quiz` (`questions[]` with `singleChoice`, `trueFalse`, `shortText`)
  - `homework` (`text`, optional `imageExt`, optional `videoUrl`)

`homework` is always visible regardless of selected format.

## Data configs

Language-specific class files:

- `src/data/5_class_stem_lesson_en.json`
- `src/data/6_class_stem_lesson_en.json`
- `src/data/5_class_stem_lesson_ua.json`
- `src/data/6_class_stem_lesson_ua.json`

## Storage behavior

- Web: class + language specific `localStorage` keys.
- Android/iOS: class + language specific JSON files in Expo document directory.
- When loading, app always uses latest module/theme config from language JSON files and keeps saved generated lessons.

## Run

```bash
npm install
npm run web
```

For Android:

```bash
npm run android
```
