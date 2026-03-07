# STEM Lesson Builder

React Native (Expo) app targeting web first and Android.

## Main flow

- Home page uses white base and displays `src/data/stem_logo.jpeg`.
- Home page has colorful round class buttons: `5` and `6`.
- Opening a class shows theme tabs (each tab has its own color).
- Each theme tab shows lessons in that theme and format labels (`Quiz`, `Story`, `Flashcards`).
- Lessons can be generated in any available format.

## Data configs

The `src/data` folder contains class configs:

- `5_class_stem_lessons.json`
- `6_class_stem_lessons.json`

Each file follows `ClassLessonsFile` shape from `src/lib/types.ts`:

- `modules[]`
- `themes[]` inside each module
- `lessons[]` inside each theme
- `exercises[]` (or `exersices[]`) inside each lesson
- `lessons[]` at root for generated lessons

## Storage behavior

- Web: class-specific `localStorage` keys.
- Android/iOS: class-specific JSON files in Expo document directory.
- Defaults are initialized from `src/data/*_class_stem_lessons.json`.

## Run

```bash
npm install
npm run web
```

For Android:

```bash
npm run android
```
