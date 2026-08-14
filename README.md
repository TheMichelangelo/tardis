# STEM Laboratory

[English version](./README_EN.md)

Кросплатформний застосунок на Flutter/Dart для проведення STEM-уроків у
5-х і 6-х класах. Один код застосунку використовується для Android, iOS та
Web. Навчальні матеріали завантажуються з локальних JSON-файлів і доступні без
окремого серверного API.

## Можливості

- вибір 5-го або 6-го класу;
- навігація за модулями, темами та уроками;
- фільтрація вправ за форматом уроку: усі, тест, історія, змагання;
- текстові вправи та запитання;
- діаграми й ребуси із локальних зображень;
- таблиці з полями для відповідей;
- інтерактивні запитання з одним варіантом відповіді;
- відкриття навчальних відео у зовнішньому застосунку або браузері;
- домашні завдання;
- вправи на встановлення відповідностей;
- адаптивний інтерфейс для телефона, планшета і браузера.
- вхід учителя за bcrypt-хешами та відновлення сесії після перезапуску.

## Підтримувані платформи

| Платформа | Стан | Результат складання |
|---|---|---|
| Android | підтримується | `build/app/outputs/flutter-apk/app-release.apk` |
| Web | підтримується | `build/web/` |
| iOS | проєкт підготовлено | архів створюється локально з Apple-підписом |

Для iOS потрібні Xcode, CocoaPods, Apple Developer Team і профіль підпису.

APK, доступний через кнопку на сайті, зберігається в репозиторії за шляхом
`web/downloads/stem-laboratory.apk`. Під час веб-збірки Flutter копіює його до
`build/web/downloads/stem-laboratory.apk`.

## Вимоги

- Flutter 3.47 або новіший;
- Dart 3.3 або новіший;
- Android SDK для Android-збірки;
- Xcode і CocoaPods для iOS-збірки;
- Chrome для локального запуску веб-версії.

Перевірити середовище:

```bash
flutter doctor -v
```

## Перший запуск

```bash
flutter pub get
flutter run -d chrome
```

Запуск на підключеному Android-пристрої:

```bash
flutter devices
flutter run -d <device-id>
```

## Release-збірки

### Web

Проєкт публікується за базовим шляхом `/tardis/`:

```bash
flutter build web --release --base-href /tardis/
```

Готові статичні файли будуть у `build/web/`. Якщо сайт розміщується в корені
домену, використайте `--base-href /`.

### Android APK

```bash
flutter build apk --release
```

APK буде створено у:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Для Google Play рекомендовано створювати App Bundle командою
`flutter build appbundle --release` і налаштувати власний release-keystore.

### Одночасне оновлення APK і Web

Скрипт перевіряє проєкт, створює Android APK, копіює його в `web/downloads`,
а потім збирає сайт із кнопкою завантаження:

```bash
./scripts/build_flutter_releases.sh
```

Після виконання додайте оновлений APK до Git разом зі змінами застосунку:

```bash
git add web/downloads/stem-laboratory.apk
```

Файл APK менший за жорстке обмеження GitHub у 100 МБ, але через його розмір
репозиторій зростатиме з кожною новою версією. Для частих релізів краще надалі
перейти на GitHub Releases або Git LFS.

### Публікація на GitHub Pages

Команда нижче запускає повний release-скрипт, створює `404.html` і `.nojekyll`,
а потім публікує `build/web` у гілку `gh-pages`:

```bash
npm run deploy
```

Опублікований сайт міститиме APK за адресою
`/tardis/downloads/stem-laboratory.apk`. Кнопка «Завантажити Android APK»
відображається лише у веб-версії.

### iOS

```bash
cd ios
pod install
cd ..
flutter build ios --release
```

Для TestFlight або App Store відкрийте `ios/Runner.xcworkspace` у Xcode,
виберіть команду розробника й створіть Archive.

## Перевірка якості

Перед створенням артефактів виконайте:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Структура Flutter-коду

```text
lib/
├── main.dart                         # точка входу
├── app.dart                          # MaterialApp і тема застосунку
├── core/
│   ├── app_assets.dart               # шляхи до ресурсів і мови даних
│   ├── app_theme.dart                # кольори та глобальна тема
│   ├── localization.dart             # українські підписи інтерфейсу
│   └── parsing.dart                  # допоміжне перетворення кольорів
├── models.dart                       # типізована модель уроків і вправ
├── repository.dart                   # завантаження JSON через AssetBundle
└── features/
    ├── home/                         # вибір класу
    ├── lessons/                      # теми, уроки та фільтри
    └── exercises/                    # відображення типів вправ
```

Каталоги `android/`, `ios/` і `web/` містять платформні проєкти. Каталог
`build/` генерується Flutter і не зберігається у Git.

## Навчальні дані

Локалізовані конфігурації класів:

- `src/data/5_class_stem_lesson_ua.json`;
- `src/data/6_class_stem_lesson_ua.json`;
- `src/data/5_class_stem_lesson_en.json`;
- `src/data/6_class_stem_lesson_en.json`.

Українська мова використовується за замовчуванням. Вибір файлу виконує
`LessonRepository`; підтримувані значення описані enum `AppLanguage`.

Зображення вправ зберігаються за схемою:

```text
src/data/<lesson-id>/<exercise-id>.<extension>
```

Усі файли, які використовує Flutter, потрібно також оголосити в секції
`flutter/assets` файла `pubspec.yaml`.

## Вхід учителя

Облікові записи зберігаються в `src/data/users.json`. Email і пароль у файлі
відсутні у відкритому вигляді — застосунок порівнює введені значення з
bcrypt-хешами `emailHash` і `passwordHash`. Перед перевіркою email переводиться
в нижній регістр, а пробіли на початку та в кінці обох полів видаляються.

Після успішного входу локально зберігаються лише ідентифікатор учителя та місце
роботи. Сесія підтримується через `shared_preferences` на Android, iOS і Web та
видаляється після натискання «Вийти».

Ця локальна авторизація підходить для керування інтерфейсом офлайн-застосунку,
але не замінює серверну перевірку прав доступу до захищених мережевих даних.

## Формат JSON

Скорочений приклад уроку:

```json
{
  "id": "lesson-1",
  "title": "Урок 1",
  "topic": "Що таке STEM",
  "formats": ["story", "quiz", "competition"],
  "exercises": [
    {
      "id": "lesson-1-ex-1",
      "label": "Прочитайте текст",
      "type": "text",
      "formats": ["story"],
      "text": "Матеріал вправи",
      "questions": ["Перше запитання?"]
    }
  ]
}
```

Для сумісності завантажувач приймає як правильне поле `exercises`, так і
історичне поле `exersices`.

Підтримувані типи вправ:

- `diagram` — локальне зображення схеми;
- `rebus` — локальне зображення ребуса;
- `table` — `columns`, необов’язкові `rows`, `dataToFill`;
- `text` — `text`, необов’язкові `questions`;
- `video` — `youtubeUrl`;
- `interactive_quiz` — масив `questions` і `answerTypes`;
- `homework` — текст домашнього завдання;
- `connect` — `column1Items` і `column2Items`.

Вправа без `formats` доступна в усіх форматах. `homework` відображається
завжди. Значення `flashcards` автоматично нормалізується до `competition`.

## Legacy React-код

Попередня реалізація React Native/Expo поки залишається в `App.tsx`, `src/`
та `package.json` лише як джерело для перевірки міграції. Release-збірки
створюються з Flutter-коду в `lib/`; команди `npm` для актуального застосунку
не потрібні.
