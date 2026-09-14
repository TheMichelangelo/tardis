/// Includes every Ukrainian letter, three apostrophes, combining characters,
/// non-breaking whitespace and a non-BMP character. Do not normalize this text.
const unicodeSample = 'АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯ\n'
    'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя\n'
    '«П’ять» / пʼять / п\'ять — № 7: 20\u00a0°C, ½ × 2 ≠ 0.\n'
    'STEM, café, cafe\u0301, и\u0306, і\u0308, 🧪\tКінець.';

const unicodeLabel = 'Українські літери: Ґґ, Єє, Іі, Її';
const unicodeBody = 'Ґанок і ґрунт. Єнот їсть яблуко. Їжак іде до лісу.\n'
    '«П’ять» / пʼять / п\'ять — це різні апострофи.\n'
    'Дослід № 7: 20\u00a0°C, ½ × 2 = 1.';
const unicodeQuestion = 'Чим відрізняються літери «І» та «Ї»?';
const unicodeSolution = '«Ї» має дві крапки. Ґ, Є, І, Ї — українські літери.';

Map<String, dynamic> unicodeTextExercise() => {
      'id': 'unicode-text',
      'label': unicodeLabel,
      'type': 'text',
      'formats': ['all'],
      'text': unicodeBody,
      'questions': [unicodeQuestion],
      'solution': unicodeSolution,
    };

Map<String, dynamic> unicodeCatalog(String marker) => {
      'modules': [
        {
          'id': 'unicode-module',
          'title': '$marker / $unicodeSample',
          'themes': [
            {
              'id': 'unicode-theme',
              'color': '#2563eb',
              'lessons': [
                {
                  'id': 'unicode-lesson',
                  'number': 99,
                  'title': '$marker / $unicodeLabel',
                  'topic': unicodeSample,
                  'formats': ['all'],
                  'exercises': [
                    unicodeTextExercise(),
                    {
                      'id': 'unicode-quiz',
                      'label': unicodeSample,
                      'type': 'interactive_quiz',
                      'questions': [
                        {
                          'id': 'unicode-question',
                          'question': unicodeSample,
                          'answerTypes': {
                            'singleChoice': [unicodeSample, 'Інша відповідь'],
                            'shortText': unicodeSample,
                          },
                        },
                      ],
                      'solution': unicodeSample,
                    },
                    {
                      'id': 'unicode-table',
                      'label': unicodeSample,
                      'type': 'table',
                      'columns': [unicodeSample],
                      'rows': [unicodeSample],
                      'dataToFill': [unicodeSample],
                    },
                    {
                      'id': 'unicode-connect',
                      'label': unicodeSample,
                      'type': 'connect',
                      'text': unicodeSample,
                      'column1Items': [unicodeSample],
                      'column2Items': [unicodeSample],
                    },
                    {
                      'id': 'unicode-homework',
                      'label': unicodeSample,
                      'type': 'homework',
                      'text': unicodeSample,
                      'solution': unicodeSample,
                      'attachments': [
                        {'label': unicodeSample, 'path': 'матеріали/ґрунт.pdf'},
                      ],
                    },
                    {
                      'id': 'unicode-video',
                      'label': unicodeSample,
                      'type': 'video',
                      'youtubeUrl': 'https://example.com/дослід',
                      'questions': [unicodeSample],
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
      'lessons': [
        {'title': unicodeSample, 'text': unicodeSample},
      ],
    };
