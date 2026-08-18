# STEM Laboratory

[English version](./README_EN.md)

Кросплатформний застосунок для STEM-уроків у 5-х і 6-х класах. Актуальна
реалізація написана на Flutter/Dart і з одного коду збирається для Android,
iOS та Web. Серверний API для перегляду навчальних матеріалів не потрібний.

## Можливості

- український та англійський інтерфейс із локалізованими матеріалами;
- вибір класу, модуля, теми й уроку;
- прямі web-посилання на клас або урок і відновлення останньої сторінки;
- фільтри «усі», «тест», «історія», «змагання»;
- показ усіх вправ або покроковий режим із кнопками «Назад» і «Далі»;
- діаграми, ребуси, текст, таблиці, відео, домашні завдання;
- інтерактивні тести з перевіркою відповіді;
- вправи на встановлення відповідностей із перевіркою пар;
- вбудоване відтворення YouTube-відео;
- друк, завантаження та поширення PDF уроку;
- адаптивний STEM-фон для телефона, планшета та браузера;
- завантаження готового Android APK кнопкою на головній сторінці.

## Функції вчителя

Облікові записи знаходяться в `src/data/users.json`. Email і пароль не
зберігаються відкритим текстом: застосунок перевіряє bcrypt-хеші. Після входу
локально зберігаються лише безпечні дані сесії, а кнопка «Вийти» очищає їх.

Авторизований учитель може:

- відкрити конструктор пропозиції уроку або окремої вправи;
- додати текст, таблицю, зображення, відео, тест, відповідності чи домашнє
  завдання;
- вибрати формати вправи та горизонтальний/вертикальний режим відповідностей;
- додати кілька структурованих запитань тесту;
- додати необов'язковий розв'язок;
- отримати готову JSON-пропозицію;
- бачити та приховувати розв'язки у вправах. Для учня розв'язки не показуються.

Локальна авторизація керує інтерфейсом офлайн-застосунку, але не замінює
серверну авторизацію для захищених мережевих даних.

## Підтримувані платформи

| Платформа | Стан | Результат складання |
|---|---|---|
| Android | підтримується | `build/app/outputs/flutter-apk/app-release.apk` |
| Web | підтримується | `build/web/` |
| iOS | проєкт підготовлено | локальна збірка або Archive з Apple-підписом |

Файл для кнопки завантаження зберігається в репозиторії за адресою
`web/downloads/stem-laboratory.apk`. Під час CI створюється новий APK і
вкладається безпосередньо в опублікований сайт.

## Встановлення Flutter

Потрібні Flutter stable, Android SDK, а для iOS також Xcode і CocoaPods.

На macOS найпростіше встановити Flutter через Homebrew:

```bash
brew install --cask flutter
flutter doctor -v
```

Якщо термінал показує `zsh: command not found: flutter`, Flutter ще не
встановлено або його каталог `bin` відсутній у `PATH`. Після інсталяції
закрийте й знову відкрийте Terminal та перевірте:

```bash
which flutter
flutter --version
flutter doctor -v
```

Для ручного встановлення завантажте Flutter SDK з офіційного сайту, розпакуйте
його і додайте `<шлях-до-flutter>/bin` до `PATH` у `~/.zshrc`.

## Перший запуск

```bash
flutter pub get
flutter run -d chrome
```

Android-пристрій або емулятор:

```bash
flutter devices
flutter run -d <device-id>
```

## Перевірка якості

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Release-збірки

### Android APK

```bash
flutter build apk --release
```

Результат: `build/app/outputs/flutter-apk/app-release.apk`.

### Web

Для GitHub Pages репозиторію `tardis`:

```bash
flutter build web --release --base-href /tardis/
```

Якщо сайт публікується в корені домену, використайте `--base-href /`. Для
форка з іншою назвою репозиторію замініть `/tardis/` на відповідний шлях.

### Android і Web однією командою

```bash
./scripts/build_flutter_releases.sh
```

Скрипт запускає аналіз і тести, створює APK, оновлює
`web/downloads/stem-laboratory.apk`, збирає Web і додає файли для коректного
перезавантаження маршрутів GitHub Pages. Оновлений APK потрібно додати до
коміту разом із кодом.

### iOS

```bash
cd ios
pod install
cd ..
flutter build ios --release
```

Для TestFlight/App Store відкрийте `ios/Runner.xcworkspace` у Xcode, виберіть
Apple Developer Team і створіть Archive. Підписаний IPA не зберігається в
репозиторії, оскільки підпис залежить від облікового запису розробника.

## Автоматична збірка GitHub Pages

Workflow `.github/workflows/flutter-pages.yml` запускається після кожного push
або merge у гілку `main` і виконує:

1. `flutter pub get`, статичний аналіз і тести;
2. release-збірку Android APK;
3. копіювання APK у каталог завантажень сайту;
4. release-збірку Flutter Web із базовим шляхом `/tardis/`;
5. публікацію `build/web` у GitHub Pages.

У налаштуваннях репозиторію один раз виберіть **Settings → Pages → Source →
GitHub Actions**. Після цього merge цієї гілки в `main` автоматично перебудує
і сайт, і APK для кнопки завантаження. Якщо основна гілка справді називається
`master`, змініть `branches: [main]` у workflow на `branches: [master]`.

## Навігація

Підтримуються маршрути:

```text
/
/login
/class/5
/class/6
/propose?class=5
/class/<5|6>/module/<module-id>/lesson/<lesson-id>
```

Старе посилання `/classes?class=5` також підтримується. На Android та iOS
останній відкритий маршрут відновлюється після перезапуску.

## Зберігання даних

За замовчуванням зміни JSON зберігаються локально через
`shared_preferences`. Дані розділені за класом і мовою. Для нативної SQLite
збірки використайте:

```bash
flutter run --dart-define=STEM_STORAGE=sqlite
flutter build apk --release --dart-define=STEM_STORAGE=sqlite
```

На Web режим SQLite автоматично переходить на JSON/local storage. Сесія,
обрана мова та навігація також зберігаються локально.

Локалізовані початкові матеріали:

- `src/data/5_class_stem_lesson_ua.json`;
- `src/data/6_class_stem_lesson_ua.json`;
- `src/data/5_class_stem_lesson_en.json`;
- `src/data/6_class_stem_lesson_en.json`.

Зображення вправ мають шлях:

```text
src/data/<lesson-id>/<exercise-id>.<extension>
```

## Формат вправ

Підтримуються `diagram`, `rebus`, `table`, `text`, `video`,
`interactive_quiz`, `homework` і `connect`. Поле `formats` може містити
`all`, `quiz`, `story`, `competition`; історичне значення `flashcards`
нормалізується до `competition`. Завантажувач приймає і `exercises`, і стару
помилкову назву `exersices`. Домашнє завдання показується в кожному форматі.

Скорочений приклад:

```json
{
  "id": "lesson-1-ex-1",
  "label": "Прочитайте текст",
  "type": "text",
  "formats": ["story"],
  "text": "Матеріал вправи",
  "questions": ["Перше запитання?"],
  "solution": "Необов'язковий розв'язок для вчителя"
}
```

## Структура актуального коду

```text
lib/
├── main.dart                 # точка входу та URL strategy
├── app.dart                  # маршрути й ініціалізація контролерів
├── core/                     # тема, локалізація, навігація, фон
├── data/storage/             # JSON та SQLite сховища
├── features/
│   ├── auth/                 # вхід і сесія вчителя
│   ├── home/                 # вибір класу та APK download
│   ├── lessons/              # класи, уроки, PDF і маршрути
│   ├── exercises/            # усі типи вправ
│   └── proposals/            # конструктор JSON-пропозицій
├── models.dart
└── repository.dart
```

Каталоги `android/`, `ios/` і `web/` містять платформні проєкти. `build/`
генерується Flutter і не зберігається в Git.

## Legacy React

Попередня Expo/React Native реалізація залишається в `App.tsx`, `src/` і
`package.json` як еталон міграції. Release-збірки створюються з Flutter-коду в
`lib/`; `npm` не потрібний для запуску актуального застосунку.
