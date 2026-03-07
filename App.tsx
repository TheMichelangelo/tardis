import { useMemo, useState } from 'react';
import {
  Image,
  Linking,
  Platform,
  Pressable,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useWindowDimensions
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import * as Print from 'expo-print';
import * as Sharing from 'expo-sharing';
import { WebView } from 'react-native-webview';
import { LessonBuilder } from './src/components/LessonBuilder';
import { RandomSTEMBackground } from './src/components/RandomSTEMBackground';
import { loadLessonsFileForClass } from './src/lib/storage';
import {
  ClassLessonsFile,
  ClassNumber,
  LessonExercise,
  InteractiveQuizExercise,
  LessonTemplate
} from './src/lib/types';

const logoImage = require('./src/data/stem_logo.jpeg');

type ScreenState =
  | { name: 'home' }
  | { name: 'class'; classNumber: ClassNumber }
  | {
      name: 'lesson';
      classNumber: ClassNumber;
      moduleId: string;
      themeId: string;
      lessonId: string;
    };

const classButtonColors: Record<ClassNumber, string> = {
  5: '#FF6B6B',
  6: '#4D96FF'
};

function resolveLessonExercises(lesson: LessonTemplate): LessonExercise[] {
  return lesson.exercises ?? lesson.exersices ?? [];
}

function InteractiveQuizFlashcards({ exercise }: { exercise: InteractiveQuizExercise }) {
  const { width } = useWindowDimensions();
  const [selectedAnswers, setSelectedAnswers] = useState<Record<string, string>>({});
  const [revealed, setRevealed] = useState<Record<string, boolean>>({});

  const choiceBoxWidth = width < 520 ? '48%' : width < 900 ? '31%' : '23%';

  return (
    <View style={styles.exerciseBlock}>
      {exercise.questions.map((question, index) => {
        const selected = selectedAnswers[question.id];
        const isRevealed = revealed[question.id];
        const correct = question.answerTypes.shortText;

        return (
          <View key={question.id} style={styles.flashcardCard}>
            <Text style={styles.flashcardTitle}>Flashcard {index + 1}</Text>
            <Text style={styles.flashcardQuestion}>{question.question}</Text>

            <View style={styles.flashcardChoicesRow}>
              {question.answerTypes.singleChoice.map((choice) => (
                <Pressable
                  key={`${question.id}-${choice}`}
                  style={[styles.choiceSquare, { width: choiceBoxWidth }]}
                  onPress={() => {
                    setSelectedAnswers((prev) => ({ ...prev, [question.id]: choice }));
                    setRevealed((prev) => ({ ...prev, [question.id]: true }));
                  }}
                >
                  <Text style={styles.choiceSquareText}>{choice}</Text>
                </Pressable>
              ))}
            </View>

            {isRevealed ? (
              <View style={styles.answerBox}>
                <Text style={styles.answerBoxText}>
                  Correct answer: {correct}
                </Text>
                {selected ? (
                  <Text style={styles.answerBoxText}>
                    Your choice: {selected}
                  </Text>
                ) : null}
              </View>
            ) : null}
          </View>
        );
      })}
    </View>
  );
}

function renderExerciseContent(lesson: LessonTemplate, exercise: LessonExercise) {
  switch (exercise.type) {
    case 'diagram': {
      const diagramPath = getExerciseImagePath(lesson, exercise);
      return (
        <View style={styles.exerciseBlock}>
          <Image source={{ uri: diagramPath }} style={styles.exerciseImage} resizeMode="contain" />
        </View>
      );
    }
    case 'rebus': {
      const rebusPath = getExerciseImagePath(lesson, exercise);
      return (
        <View style={styles.exerciseBlock}>
          <Image source={{ uri: rebusPath }} style={styles.exerciseImage} resizeMode="contain" />
        </View>
      );
    }
    case 'table':
      return (
        <View style={styles.exerciseBlock}>
          <Text style={styles.exerciseText}>Columns: {exercise.columns.join(', ')}</Text>
          <Text style={styles.exerciseText}>
            Rows: {exercise.rows && exercise.rows.length > 0 ? exercise.rows.join(', ') : 'No row names'}
          </Text>
          <Text style={styles.exerciseText}>Data to fill: {exercise.dataToFill.join(', ')}</Text>
        </View>
      );
    case 'text':
      return (
        <View style={styles.exerciseBlock}>
          <Text style={styles.exerciseText}>{exercise.text}</Text>
          {exercise.questions && exercise.questions.length > 0 ? (
            <View style={styles.questionList}>
              {exercise.questions.map((question, index) => (
                <Text key={`${exercise.id}-q-${index}`} style={styles.exerciseText}>
                  {index + 1}. {question}
                </Text>
              ))}
            </View>
          ) : null}
        </View>
      );
    case 'video':
      const embedUrl = getYoutubeEmbedUrl(exercise.youtubeUrl);
      const IFrame = 'iframe' as unknown as any;
      return (
        <View style={styles.exerciseBlock}>
          {embedUrl ? (
            Platform.OS === 'web' ? (
              <View style={styles.videoFrameWrapper}>
                <IFrame
                  src={embedUrl}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                  style={styles.webVideoFrame}
                />
              </View>
            ) : (
              <View style={styles.videoFrameWrapper}>
                <WebView source={{ uri: embedUrl }} style={styles.nativeVideoFrame} />
              </View>
            )
          ) : (
            <Pressable
              style={styles.openVideoButton}
              onPress={() => Linking.openURL(exercise.youtubeUrl)}
            >
              <Text style={styles.openVideoButtonText}>Open YouTube Video</Text>
            </Pressable>
          )}
          {exercise.questions && exercise.questions.length > 0 ? (
            <View style={styles.questionList}>
              {exercise.questions.map((question, index) => (
                <Text key={`${exercise.id}-video-q-${index}`} style={styles.exerciseText}>
                  {index + 1}. {question}
                </Text>
              ))}
            </View>
          ) : null}
        </View>
      );
    case 'interactive_quiz':
      return <InteractiveQuizFlashcards exercise={exercise} />;
    default:
      return null;
  }
}

function escapeHtml(value: string) {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function getExerciseImagePath(lesson: LessonTemplate, exercise: LessonExercise) {
  if (exercise.type !== 'diagram' && exercise.type !== 'rebus') {
    return '';
  }
  const ext = exercise.imageExt ?? 'png';
  return `${lesson.id}/${exercise.id}.${ext}`;
}

function getQrCodeUrl(value: string) {
  return `https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent(
    value
  )}`;
}

function getYoutubeEmbedUrl(url: string) {
  const longForm = url.match(/[?&]v=([a-zA-Z0-9_-]{6,})/);
  if (longForm?.[1]) {
    return `https://www.youtube.com/embed/${longForm[1]}`;
  }
  const shortForm = url.match(/youtu\.be\/([a-zA-Z0-9_-]{6,})/);
  if (shortForm?.[1]) {
    return `https://www.youtube.com/embed/${shortForm[1]}`;
  }
  return '';
}

export default function App() {
  const { width } = useWindowDimensions();
  const [screen, setScreen] = useState<ScreenState>({ name: 'home' });
  const [data, setData] = useState<ClassLessonsFile | null>(null);
  const [error, setError] = useState('');
  const [isLoadingClass, setIsLoadingClass] = useState(false);
  const [viewMode, setViewMode] = useState<'all' | 'single'>('single');
  const [exerciseIndex, setExerciseIndex] = useState(0);

  const openClass = async (classNumber: ClassNumber) => {
    setIsLoadingClass(true);
    setError('');

    try {
      const classData = await loadLessonsFileForClass(classNumber);
      setData(classData);
      setScreen({ name: 'class', classNumber });
    } catch {
      setError('Failed to load class lessons JSON.');
    } finally {
      setIsLoadingClass(false);
    }
  };

  const openLesson = (template: LessonTemplate, moduleId: string, themeId: string) => {
    if (screen.name !== 'class') {
      return;
    }

    setViewMode('single');
    setExerciseIndex(0);
    setError('');
    setScreen({
      name: 'lesson',
      classNumber: screen.classNumber,
      moduleId,
      themeId,
      lessonId: template.id
    });
  };

  const goHome = () => {
    setScreen({ name: 'home' });
    setData(null);
    setError('');
  };

  const goToClassThemes = (classNumber: ClassNumber) => {
    setScreen({ name: 'class', classNumber });
    setError('');
  };

  const lessonContext = useMemo(() => {
    if (screen.name !== 'lesson' || !data) {
      return null;
    }

    const module = data.modules.find((item) => item.id === screen.moduleId);
    const theme = module?.themes.find((item) => item.id === screen.themeId);
    const lesson = theme?.lessons.find((item) => item.id === screen.lessonId);

    if (!module || !theme || !lesson) {
      return null;
    }

    return {
      module,
      theme,
      lesson,
      exercises: resolveLessonExercises(lesson)
    };
  }, [data, screen]);

  const singleExercise = lessonContext?.exercises[exerciseIndex];
  const isSmall = width < 760;

  const downloadLessonPdf = async () => {
    if (!lessonContext) {
      return;
    }

    const splitIndex =
      lessonContext.exercises.length > 4
        ? Math.ceil(lessonContext.exercises.length / 2)
        : -1;

    const exerciseHtml = lessonContext.exercises
      .map((exercise, index) => {
        const pageBreak = splitIndex > 0 && index === splitIndex ? '<div class="page-break"></div>' : '';
        const title = `<h3>${index + 1}. ${escapeHtml(exercise.label)}</h3>`;

        if (exercise.type === 'diagram' || exercise.type === 'rebus') {
          const imagePath = escapeHtml(getExerciseImagePath(lessonContext.lesson, exercise));
          return `
            ${pageBreak}
            <section class="card">
              ${title}
              <p><strong>Type:</strong> ${escapeHtml(exercise.type)}</p>
              <img src="${imagePath}" alt="${escapeHtml(exercise.label)}" />
            </section>
          `;
        }

        if (exercise.type === 'table') {
          return `
            ${pageBreak}
            <section class="card">
              ${title}
              <p><strong>Type:</strong> table</p>
              <p><strong>Columns:</strong> ${escapeHtml(exercise.columns.join(', '))}</p>
              <p><strong>Rows:</strong> ${escapeHtml(
                exercise.rows && exercise.rows.length > 0
                  ? exercise.rows.join(', ')
                  : 'No row names'
              )}</p>
              <p><strong>Data to fill:</strong> ${escapeHtml(exercise.dataToFill.join(', '))}</p>
            </section>
          `;
        }

        if (exercise.type === 'text') {
          const questions = exercise.questions?.length
            ? `<ul>${exercise.questions
                .map((question) => `<li>${escapeHtml(question)}</li>`)
                .join('')}</ul>`
            : '';
          return `
            ${pageBreak}
            <section class="card">
              ${title}
              <p><strong>Type:</strong> text</p>
              <p>${escapeHtml(exercise.text)}</p>
              ${questions}
            </section>
          `;
        }

        if (exercise.type === 'video') {
          const safeUrl = escapeHtml(exercise.youtubeUrl);
          const qrUrl = escapeHtml(getQrCodeUrl(exercise.youtubeUrl));
          const questions = exercise.questions?.length
            ? `<ul>${exercise.questions
                .map((question) => `<li>${escapeHtml(question)}</li>`)
                .join('')}</ul>`
            : '';
          return `
            ${pageBreak}
            <section class="card">
              ${title}
              <p><strong>Type:</strong> video</p>
              <img src="${qrUrl}" alt="QR code to video" />
              <p><a href="${safeUrl}" target="_blank" rel="noopener noreferrer">Open YouTube video</a></p>
              ${questions}
            </section>
          `;
        }

        if (exercise.type === 'interactive_quiz') {
          const questions = exercise.questions
            .map(
              (question, qIndex) => `
                <div class="quiz">
                  <p><strong>Flashcard ${qIndex + 1}:</strong> ${escapeHtml(question.question)}</p>
                  <p>Single choice: ${escapeHtml(question.answerTypes.singleChoice.join(' | '))}</p>
                  <p>True/False: ${escapeHtml(question.answerTypes.trueFalse)}</p>
                  <p>Short text: ${escapeHtml(question.answerTypes.shortText)}</p>
                </div>
              `
            )
            .join('');
          return `
            ${pageBreak}
            <section class="card">
              ${title}
              <p><strong>Type:</strong> interactive quiz</p>
              ${questions}
            </section>
          `;
        }

        return '';
      })
      .join('');

    const html = `
      <html>
        <head>
          <meta charset="utf-8" />
          <style>
            @page { size: A4; margin: 14mm; }
            body { font-family: Arial, sans-serif; padding: 20px; }
            h1 { margin-bottom: 2px; }
            h2 { margin-top: 2px; color: #475569; font-size: 14px; }
            .card { border: 1px solid #cbd5e1; border-radius: 8px; padding: 12px; margin-top: 10px; page-break-inside: avoid; }
            .page-break { break-before: page; page-break-before: always; height: 0; }
            img { width: 100%; max-width: 540px; max-height: 320px; object-fit: contain; border-radius: 6px; background: #f8fafc; }
            .quiz { background: #f8fafc; border-radius: 6px; padding: 8px; margin-top: 6px; }
          </style>
        </head>
        <body>
          <h1>${escapeHtml(lessonContext.lesson.title)}</h1>
          <h2>Module: ${escapeHtml(lessonContext.module.title)} | Theme: ${escapeHtml(
      lessonContext.theme.title
    )}</h2>
          ${exerciseHtml}
        </body>
      </html>
    `;

    try {
      if (Platform.OS === 'web') {
        await Print.printAsync({ html });
        return;
      }

      const file = await Print.printToFileAsync({ html });

      if (await Sharing.isAvailableAsync()) {
        await Sharing.shareAsync(file.uri, {
          mimeType: 'application/pdf',
          dialogTitle: 'Download lesson PDF'
        });
        return;
      }

      await Linking.openURL(file.uri);
    } catch {
      setError('Could not generate PDF file for this lesson.');
    }
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar style="dark" />
      <RandomSTEMBackground logoSource={logoImage} />

      {screen.name === 'home' ? (
        <ScrollView contentContainerStyle={styles.homeContainer}>
          <Image source={logoImage} style={styles.logo} resizeMode="contain" />
          <View style={styles.classButtonRow}>
            <Pressable
              style={[styles.classButton, { backgroundColor: classButtonColors[5] }]}
              onPress={() => openClass(5)}
            >
              <Text style={styles.classButtonText}>5</Text>
            </Pressable>
            <Pressable
              style={[styles.classButton, { backgroundColor: classButtonColors[6] }]}
              onPress={() => openClass(6)}
            >
              <Text style={styles.classButtonText}>6</Text>
            </Pressable>
          </View>

          {isLoadingClass ? <Text style={styles.infoText}>Loading...</Text> : null}
          {error ? <Text style={styles.errorText}>{error}</Text> : null}
        </ScrollView>
      ) : null}

      {screen.name === 'class' ? (
        <ScrollView contentContainerStyle={styles.classContainer}>
          <Pressable onPress={goHome} style={styles.backButton}>
            <Text style={styles.backButtonText}>Back</Text>
          </Pressable>

          <Text style={styles.classTitle}>Class {screen.classNumber}</Text>

          {data ? (
            <LessonBuilder key={`class-${screen.classNumber}`} data={data} onOpenLesson={openLesson} />
          ) : (
            <Text style={styles.infoText}>Loading class data...</Text>
          )}

          {error ? <Text style={styles.errorText}>{error}</Text> : null}
        </ScrollView>
      ) : null}

      {screen.name === 'lesson' ? (
        <ScrollView contentContainerStyle={styles.lessonPageContainer}>
          <View style={styles.lessonTopBar}>
            <Pressable
              onPress={() => goToClassThemes(screen.classNumber)}
              style={styles.backButton}
            >
              <Text style={styles.backButtonText}>Back to Themes</Text>
            </Pressable>
            <Pressable onPress={downloadLessonPdf} style={styles.downloadButton}>
              <Text style={styles.downloadButtonText}>Download PDF</Text>
            </Pressable>
          </View>

          {lessonContext ? (
            <>
              <Text style={[styles.classTitle, isSmall && styles.classTitleSmall]}>
                {lessonContext.lesson.title}
              </Text>
              <Text style={styles.lessonMetaText}>Module: {lessonContext.module.title}</Text>
              <Text style={styles.lessonMetaText}>Theme: {lessonContext.theme.title}</Text>

              <View style={styles.modeRow}>
                <Pressable
                  onPress={() => {
                    setViewMode('all');
                    setExerciseIndex(0);
                  }}
                  style={[styles.modeButton, viewMode === 'all' && styles.modeButtonActive]}
                >
                  <Text style={[styles.modeButtonText, viewMode === 'all' && styles.modeButtonTextActive]}>
                    See all exercises
                  </Text>
                </Pressable>
                <Pressable
                  onPress={() => {
                    setViewMode('single');
                    setExerciseIndex(0);
                  }}
                  style={[styles.modeButton, viewMode === 'single' && styles.modeButtonActive]}
                >
                  <Text
                    style={[styles.modeButtonText, viewMode === 'single' && styles.modeButtonTextActive]}
                  >
                    One by one
                  </Text>
                </Pressable>
              </View>

              {viewMode === 'single' ? (
                <>
                  <Text style={styles.counterText}>
                    {lessonContext.exercises.length === 0
                      ? '0 of 0 exercises'
                      : `${exerciseIndex + 1} of ${lessonContext.exercises.length} exercises`}
                  </Text>

                  {singleExercise ? (
                    <View style={styles.exerciseCard}>
                      <Text style={styles.exerciseTitle}>{singleExercise.label}</Text>
                      {renderExerciseContent(lessonContext.lesson, singleExercise)}
                    </View>
                  ) : (
                    <Text style={styles.infoText}>No exercises in this lesson.</Text>
                  )}

                  <View style={styles.navRow}>
                    <Pressable
                      onPress={() => setExerciseIndex((prev) => Math.max(0, prev - 1))}
                      style={[styles.navButton, exerciseIndex === 0 && styles.navButtonDisabled]}
                      disabled={exerciseIndex === 0}
                    >
                      <Text style={styles.navButtonText}>Prev</Text>
                    </Pressable>
                    <Pressable
                      onPress={() =>
                        setExerciseIndex((prev) =>
                          Math.min(lessonContext.exercises.length - 1, prev + 1)
                        )
                      }
                      style={[
                        styles.navButton,
                        (lessonContext.exercises.length === 0 ||
                          exerciseIndex === lessonContext.exercises.length - 1) &&
                          styles.navButtonDisabled
                      ]}
                      disabled={
                        lessonContext.exercises.length === 0 ||
                        exerciseIndex === lessonContext.exercises.length - 1
                      }
                    >
                      <Text style={styles.navButtonText}>Next</Text>
                    </Pressable>
                  </View>
                </>
              ) : (
                <View style={styles.exerciseList}>
                  {lessonContext.exercises.length === 0 ? (
                    <Text style={styles.infoText}>No exercises in this lesson.</Text>
                  ) : (
                    lessonContext.exercises.map((exercise) => (
                      <View key={exercise.id} style={styles.exerciseCard}>
                        <Text style={styles.exerciseTitle}>{exercise.label}</Text>
                        {renderExerciseContent(lessonContext.lesson, exercise)}
                      </View>
                    ))
                  )}
                </View>
              )}
            </>
          ) : (
            <Text style={styles.errorText}>Lesson not found in current data.</Text>
          )}
        </ScrollView>
      ) : null}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    backgroundColor: '#FFFFFF',
    flex: 1
  },
  homeContainer: {
    alignItems: 'center',
    gap: 10,
    paddingBottom: 40,
    paddingHorizontal: 24,
    paddingTop: 28
  },
  logo: {
    height: 280,
    marginBottom: 16,
    maxWidth: 520,
    width: '100%'
  },
  classButtonRow: {
    flexDirection: 'row',
    gap: 20,
    marginBottom: 8
  },
  classButton: {
    alignItems: 'center',
    borderRadius: 999,
    height: 92,
    justifyContent: 'center',
    width: 92
  },
  classButtonText: {
    color: '#FFFFFF',
    fontSize: 36,
    fontWeight: '800'
  },
  classContainer: {
    paddingBottom: 40,
    paddingHorizontal: 20,
    paddingTop: 12
  },
  lessonPageContainer: {
    paddingBottom: 40,
    paddingHorizontal: 20,
    paddingTop: 12
  },
  lessonTopBar: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  backButton: {
    alignSelf: 'flex-start',
    backgroundColor: 'rgba(226,232,240,0.95)',
    borderRadius: 10,
    paddingHorizontal: 18,
    paddingVertical: 12
  },
  downloadButton: {
    backgroundColor: 'rgba(37,99,235,0.95)',
    borderRadius: 10,
    paddingHorizontal: 14,
    paddingVertical: 10
  },
  downloadButtonText: {
    color: '#FFFFFF',
    fontSize: 13,
    fontWeight: '700'
  },
  backButtonText: {
    color: '#1E293B',
    fontSize: 16,
    fontWeight: '700'
  },
  classTitle: {
    alignSelf: 'center',
    color: '#0F172A',
    fontSize: 28,
    fontWeight: '800',
    marginTop: 12,
    textAlign: 'center'
  },
  classTitleSmall: {
    fontSize: 22
  },
  lessonMetaText: {
    color: '#334155',
    fontSize: 14,
    marginTop: 4,
    textAlign: 'center'
  },
  modeRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    justifyContent: 'center',
    marginTop: 14
  },
  modeButton: {
    backgroundColor: '#E2E8F0',
    borderRadius: 999,
    paddingHorizontal: 14,
    paddingVertical: 8
  },
  modeButtonActive: {
    backgroundColor: '#1D4ED8'
  },
  modeButtonText: {
    color: '#1E293B',
    fontSize: 13,
    fontWeight: '700'
  },
  modeButtonTextActive: {
    color: '#FFFFFF'
  },
  counterText: {
    color: '#0F172A',
    fontSize: 15,
    fontWeight: '700',
    marginTop: 12,
    textAlign: 'center'
  },
  exerciseList: {
    marginTop: 6
  },
  exerciseCard: {
    backgroundColor: 'rgba(255,255,255,0.94)',
    borderColor: '#CBD5E1',
    borderRadius: 12,
    borderWidth: 1,
    marginTop: 10,
    padding: 12
  },
  exerciseTitle: {
    color: '#0F172A',
    fontSize: 17,
    fontWeight: '700'
  },
  exerciseBlock: {
    marginTop: 8
  },
  exerciseImage: {
    backgroundColor: '#F8FAFC',
    borderRadius: 8,
    height: 220,
    width: '100%'
  },
  videoFrameWrapper: {
    backgroundColor: '#000000',
    borderRadius: 8,
    height: 220,
    overflow: 'hidden',
    width: '100%'
  },
  webVideoFrame: {
    borderWidth: 0,
    height: '100%',
    width: '100%'
  },
  nativeVideoFrame: {
    flex: 1
  },
  openVideoButton: {
    alignSelf: 'flex-start',
    backgroundColor: '#DC2626',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 8
  },
  openVideoButtonText: {
    color: '#FFFFFF',
    fontSize: 13,
    fontWeight: '700'
  },
  exerciseText: {
    color: '#1E293B',
    fontSize: 14,
    lineHeight: 20,
    marginTop: 6
  },
  questionList: {
    marginTop: 4
  },
  quizCard: {
    backgroundColor: '#F8FAFC',
    borderRadius: 10,
    marginTop: 8,
    padding: 10
  },
  quizTitle: {
    color: '#1D4ED8',
    fontSize: 13,
    fontWeight: '800'
  },
  flashcardCard: {
    backgroundColor: '#F8FAFC',
    borderRadius: 10,
    marginTop: 8,
    padding: 10
  },
  flashcardTitle: {
    color: '#1D4ED8',
    fontSize: 13,
    fontWeight: '800'
  },
  flashcardQuestion: {
    color: '#000000',
    fontSize: 15,
    fontStyle: 'italic',
    marginTop: 6
  },
  flashcardChoicesRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 10
  },
  choiceSquare: {
    alignItems: 'center',
    backgroundColor: '#E2E8F0',
    borderColor: '#94A3B8',
    borderRadius: 8,
    borderWidth: 1,
    justifyContent: 'center',
    minHeight: 76,
    paddingHorizontal: 8,
    paddingVertical: 8
  },
  choiceSquareText: {
    color: '#0F172A',
    fontSize: 13,
    fontWeight: '700',
    textAlign: 'center'
  },
  answerBox: {
    backgroundColor: '#ECFEFF',
    borderColor: '#67E8F9',
    borderRadius: 8,
    borderWidth: 1,
    marginTop: 10,
    padding: 8
  },
  answerBoxText: {
    color: '#0F172A',
    fontSize: 13,
    fontWeight: '700'
  },
  navRow: {
    flexDirection: 'row',
    gap: 10,
    justifyContent: 'center',
    marginTop: 14
  },
  navButton: {
    backgroundColor: '#1D4ED8',
    borderRadius: 10,
    paddingHorizontal: 18,
    paddingVertical: 10
  },
  navButtonDisabled: {
    backgroundColor: '#93C5FD'
  },
  navButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '700'
  },
  infoText: {
    color: '#475569',
    fontSize: 14,
    marginTop: 12,
    textAlign: 'center'
  },
  errorText: {
    color: '#B91C1C',
    fontSize: 14,
    marginTop: 12,
    textAlign: 'center'
  }
});
