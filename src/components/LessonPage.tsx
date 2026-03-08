import { useEffect, useMemo, useState } from 'react';
import {
  Image,
  Linking,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useWindowDimensions
} from 'react-native';
import * as Print from 'expo-print';
import * as Sharing from 'expo-sharing';
import { WebView } from 'react-native-webview';
import { formatExerciseTypeLabel, formatTypeLabel, tr } from '../localization';
import {
  ClassNumber,
  ExerciseFormat,
  InteractiveQuizExercise,
  LessonExercise,
  LessonFormat,
  LessonTemplate,
  LessonType
} from '../lib/types';

type Props = {
  classNumber: ClassNumber;
  moduleTitle: string;
  lesson: LessonTemplate;
  error: string;
  onBack: () => void;
  onError: (message: string) => void;
};

function resolveLessonExercises(lesson: LessonTemplate): LessonExercise[] {
  return lesson.exercises ?? lesson.exersices ?? [];
}

function normalizeFormat(format: LessonFormat | ExerciseFormat): 'all' | LessonType {
  if (format === 'all') {
    return 'all';
  }
  if (format === 'flashcards') {
    return 'competition';
  }
  return format;
}

function formatLabel(format: 'all' | LessonType) {
  if (format === 'all') {
    return tr('allExercises');
  }
  return formatTypeLabel(format);
}

function resolveExerciseFormats(exercise: LessonExercise): ('all' | LessonType)[] {
  const raw = exercise.formats ?? [];
  if (raw.length === 0) {
    return ['all'];
  }
  const normalized = Array.from(new Set(raw.map((item) => normalizeFormat(item))));
  if (normalized.length === 1 && normalized[0] === 'all') {
    return ['all'];
  }
  return normalized;
}

function isExerciseVisibleForFormat(exercise: LessonExercise, selectedFormat: 'all' | LessonType) {
  if (exercise.type === 'homework') {
    return true;
  }
  if (selectedFormat === 'all') {
    return true;
  }
  const formats = resolveExerciseFormats(exercise);
  if (formats.length === 0 || formats.includes('all')) {
    return true;
  }
  return formats.includes(selectedFormat);
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
  return `src/data/${lesson.id}/${exercise.id}.${ext}`;
}

function getHomeworkImagePath(lesson: LessonTemplate, exercise: LessonExercise) {
  if (exercise.type !== 'homework') {
    return '';
  }
  const ext = exercise.imageExt ?? 'png';
  return `src/data/${lesson.id}/${exercise.id}.${ext}`;
}

function getQrCodeUrl(value: string) {
  return `https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent(value)}`;
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

function getEmbeddableVideoUrl(url: string) {
  const yt = getYoutubeEmbedUrl(url);
  if (yt) {
    return yt;
  }
  return url;
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
            <Text style={styles.flashcardTitle}>{tr('flashcard')} {index + 1}</Text>
            <Text style={styles.flashcardQuestion}>{question.question}</Text>

            <View style={styles.flashcardChoicesRow}>
              {question.answerTypes.singleChoice.map((choice) => (
                <Pressable
                  key={`${question.id}-${choice}`}
                  style={[
                    styles.choiceSquare,
                    { width: choiceBoxWidth },
                    selected === choice &&
                      (choice === correct ? styles.choiceSquareCorrect : styles.choiceSquareWrong)
                  ]}
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
                <Text style={styles.answerBoxText}>{tr('correctAnswer')}: {correct}</Text>
                {selected ? <Text style={styles.answerBoxText}>{tr('yourChoice')}: {selected}</Text> : null}
              </View>
            ) : null}
          </View>
        );
      })}
    </View>
  );
}

function renderExerciseContent(lesson: LessonTemplate, exercise: LessonExercise, videoHeight: number) {
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
      const columnCount = Math.max(exercise.columns.length, 1);
      const generatedRowsCount = Math.floor(exercise.dataToFill.length / columnCount);
      const generatedRows = Array.from({ length: generatedRowsCount }, (_, rowIndex) =>
        exercise.dataToFill.slice(rowIndex * columnCount, rowIndex * columnCount + columnCount)
      );
      return (
        <View style={styles.exerciseBlock}>
          <View style={styles.tableWrap}>
            <View style={styles.tableHeaderRow}>
              {exercise.rows && exercise.rows.length > 0 ? (
                <View style={[styles.tableCell, styles.tableHeaderCell]} />
              ) : null}
              {exercise.columns.map((column) => (
                <View key={`col-${column}`} style={[styles.tableCell, styles.tableHeaderCell]}>
                  <Text style={styles.tableHeaderText}>{column}</Text>
                </View>
              ))}
            </View>

            {(exercise.rows && exercise.rows.length > 0
              ? exercise.rows.map((row, index) => (
                  <View key={`row-${row}-${index}`} style={styles.tableDataRow}>
                    <View style={[styles.tableCell, styles.tableRowLabelCell]}>
                      <Text style={styles.tableRowLabelText}>{row}</Text>
                    </View>
                    {exercise.columns.map((column, colIndex) => (
                      <View key={`cell-${row}-${column}-${colIndex}`} style={styles.tableCell}>
                        <Text style={styles.tableDataText}> </Text>
                      </View>
                    ))}
                  </View>
                ))
              : generatedRows.map((_, index) => (
                  <View key={`gen-row-${index}`} style={styles.tableDataRow}>
                    {exercise.columns.map((column, colIndex) => (
                      <View key={`gen-cell-${index}-${column}-${colIndex}`} style={styles.tableCell}>
                        <Text style={styles.tableDataText}> </Text>
                      </View>
                    ))}
                  </View>
                )))}
          </View>
          <Text style={styles.exerciseText}>{tr('dataToFill')}:</Text>
          {exercise.dataToFill.map((item, index) => (
            <Text key={`fill-${index}-${item}`} style={styles.exerciseText}>
              {index + 1}. {item}
            </Text>
          ))}
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
    case 'video': {
      const embedUrl = getEmbeddableVideoUrl(exercise.youtubeUrl);
      const IFrame = 'iframe' as any;
      return (
        <View style={styles.exerciseBlock}>
          {embedUrl ? (
            Platform.OS === 'web' ? (
              <View style={[styles.videoFrameWrapper, { height: videoHeight }]}> 
                <IFrame
                  src={embedUrl}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                  style={{ border: '0', height: '100%', width: '100%' }}
                />
              </View>
            ) : (
              <View style={[styles.videoFrameWrapper, { height: videoHeight }]}> 
                <WebView source={{ uri: embedUrl }} style={styles.nativeVideoFrame} />
              </View>
            )
          ) : (
            <Pressable style={styles.openVideoButton} onPress={() => Linking.openURL(exercise.youtubeUrl)}>
              <Text style={styles.openVideoButtonText}>{tr('openYoutubeVideo')}</Text>
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
    }
    case 'homework': {
      const imagePath = getHomeworkImagePath(lesson, exercise);
      const embeddedVideo = exercise.videoUrl ? getEmbeddableVideoUrl(exercise.videoUrl) : '';
      const IFrame = 'iframe' as any;
      return (
        <View style={styles.exerciseBlock}>
          <Text style={styles.exerciseText}>{exercise.text}</Text>
          {imagePath ? <Image source={{ uri: imagePath }} style={styles.exerciseImage} resizeMode="contain" /> : null}
          {embeddedVideo ? (
            Platform.OS === 'web' ? (
              <View style={[styles.videoFrameWrapper, { height: videoHeight }]}> 
                <IFrame
                  src={embeddedVideo}
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                  style={{ border: '0', height: '100%', width: '100%' }}
                />
              </View>
            ) : (
              <View style={[styles.videoFrameWrapper, { height: videoHeight }]}> 
                <WebView source={{ uri: embeddedVideo }} style={styles.nativeVideoFrame} />
              </View>
            )
          ) : null}
        </View>
      );
    }
    case 'interactive_quiz':
      return <InteractiveQuizFlashcards exercise={exercise} />;
    default:
      return null;
  }
}

export function LessonPage({ classNumber, moduleTitle, lesson, error, onBack, onError }: Props) {
  const { width } = useWindowDimensions();
  const [viewMode, setViewMode] = useState<'all' | 'single'>('single');
  const [selectedFormat, setSelectedFormat] = useState<'all' | LessonType>('all');
  const [exerciseIndex, setExerciseIndex] = useState(0);

  const exercises = useMemo(() => resolveLessonExercises(lesson), [lesson]);
  const availableSpecificFormats = useMemo<LessonType[]>(() => {
    const lessonFormats = lesson.formats.map((item) => normalizeFormat(item));
    const exerciseFormats = exercises.flatMap((exercise) => resolveExerciseFormats(exercise));
    const combined = Array.from(new Set([...lessonFormats, ...exerciseFormats]));
    return combined.filter((item): item is LessonType => item !== 'all');
  }, [lesson.formats, exercises]);

  const filteredExercises = useMemo(
    () => exercises.filter((exercise) => isExerciseVisibleForFormat(exercise, selectedFormat)),
    [exercises, selectedFormat]
  );

  useEffect(() => {
    setExerciseIndex(0);
  }, [selectedFormat]);

  useEffect(() => {
    if (exerciseIndex > Math.max(filteredExercises.length - 1, 0)) {
      setExerciseIndex(0);
    }
  }, [exerciseIndex, filteredExercises.length]);

  const singleExercise = filteredExercises[exerciseIndex];
  const isSmall = width < 760;
  const videoHeight = Math.max(190, Math.min(430, Math.round(width * 0.56)));

  const downloadLessonPdf = async () => {
    const splitIndex = exercises.length > 4 ? Math.ceil(exercises.length / 2) : -1;

    const exerciseHtml = exercises
      .map((exercise, index) => {
        const pageBreak = splitIndex > 0 && index === splitIndex ? '<div class="page-break"></div>' : '';
        const title = `<h3>${index + 1}. ${escapeHtml(exercise.label)}</h3>`;

        if (exercise.type === 'diagram' || exercise.type === 'rebus') {
          const imagePath = escapeHtml(getExerciseImagePath(lesson, exercise));
          return `${pageBreak}<section class="card">${title}<p><strong>${escapeHtml(tr('type'))}:</strong> ${escapeHtml(formatExerciseTypeLabel(exercise.type))}</p><img src="${imagePath}" alt="${escapeHtml(exercise.label)}" /></section>`;
        }

        if (exercise.type === 'table') {
          return `${pageBreak}<section class="card">${title}<p><strong>${escapeHtml(tr('type'))}:</strong> ${escapeHtml(formatExerciseTypeLabel(exercise.type))}</p><p><strong>${escapeHtml(tr('columns'))}:</strong> ${escapeHtml(exercise.columns.join(', '))}</p><p><strong>${escapeHtml(tr('rows'))}:</strong> ${escapeHtml(exercise.rows && exercise.rows.length > 0 ? exercise.rows.join(', ') : tr('noRowNames'))}</p><p><strong>${escapeHtml(tr('dataToFill'))}:</strong> ${escapeHtml(exercise.dataToFill.join(', '))}</p></section>`;
        }

        if (exercise.type === 'text') {
          const questions = exercise.questions?.length
            ? `<ul>${exercise.questions.map((question) => `<li>${escapeHtml(question)}</li>`).join('')}</ul>`
            : '';
          return `${pageBreak}<section class="card">${title}<p><strong>${escapeHtml(tr('type'))}:</strong> ${escapeHtml(formatExerciseTypeLabel(exercise.type))}</p><p>${escapeHtml(exercise.text)}</p>${questions}</section>`;
        }

        if (exercise.type === 'video') {
          const safeUrl = escapeHtml(exercise.youtubeUrl);
          const qrUrl = escapeHtml(getQrCodeUrl(exercise.youtubeUrl));
          const questions = exercise.questions?.length
            ? `<ul>${exercise.questions.map((question) => `<li>${escapeHtml(question)}</li>`).join('')}</ul>`
            : '';
          return `${pageBreak}<section class="card">${title}<p><strong>${escapeHtml(tr('type'))}:</strong> ${escapeHtml(formatExerciseTypeLabel(exercise.type))}</p><img src="${qrUrl}" alt="QR code to video" /><p><a href="${safeUrl}" target="_blank" rel="noopener noreferrer">${escapeHtml(tr('watchYoutubeVideo'))}</a></p>${questions}</section>`;
        }

        if (exercise.type === 'interactive_quiz') {
          const questions = exercise.questions
            .map((question, qIndex) => `<div class="quiz"><p><strong>${escapeHtml(tr('flashcard'))} ${qIndex + 1}:</strong> ${escapeHtml(question.question)}</p><p>Single choice: ${escapeHtml(question.answerTypes.singleChoice.join(' | '))}</p><p>True/False: ${escapeHtml(question.answerTypes.trueFalse)}</p><p>Short text: ${escapeHtml(question.answerTypes.shortText)}</p></div>`)
            .join('');
          return `${pageBreak}<section class="card">${title}<p><strong>${escapeHtml(tr('type'))}:</strong> ${escapeHtml(formatExerciseTypeLabel(exercise.type))}</p>${questions}</section>`;
        }

        if (exercise.type === 'homework') {
          const imagePath = escapeHtml(getHomeworkImagePath(lesson, exercise));
          const safeVideo = exercise.videoUrl ? escapeHtml(exercise.videoUrl) : '';
          const qrVideo = exercise.videoUrl ? escapeHtml(getQrCodeUrl(exercise.videoUrl)) : '';
          return `${pageBreak}<section class="card">${title}<p><strong>${escapeHtml(tr('type'))}:</strong> ${escapeHtml(formatExerciseTypeLabel(exercise.type))}</p><p>${escapeHtml(exercise.text)}</p>${imagePath ? `<img src="${imagePath}" alt="Homework image" />` : ''}${safeVideo ? `<img src="${qrVideo}" alt="QR code to homework video" /><p><a href="${safeVideo}" target="_blank" rel="noopener noreferrer">${escapeHtml(tr('watchYoutubeVideo'))}</a></p>` : ''}</section>`;
        }

        return '';
      })
      .join('');

    const html = `
      <html><head><meta charset="utf-8" /><style>
      @page { size: A4; margin: 14mm; }
      body { font-family: Arial, sans-serif; padding: 20px; }
      h1 { margin-bottom: 2px; }
      h2 { margin-top: 2px; color: #475569; font-size: 14px; }
      .card { border: 1px solid #cbd5e1; border-radius: 8px; padding: 12px; margin-top: 10px; page-break-inside: avoid; }
      .page-break { break-before: page; page-break-before: always; height: 0; }
      img { width: 100%; max-width: 540px; max-height: 320px; object-fit: contain; border-radius: 6px; background: #f8fafc; }
      .quiz { background: #f8fafc; border-radius: 6px; padding: 8px; margin-top: 6px; }
      </style></head><body>
      <h1>${escapeHtml(lesson.title)}</h1>
      <h2>${escapeHtml(tr('module'))}: ${escapeHtml(moduleTitle)}</h2>
      ${exerciseHtml}
      </body></html>
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
          dialogTitle: tr('downloadPdfDialog')
        });
        return;
      }

      await Linking.openURL(file.uri);
    } catch {
      onError(tr('errorDownloadPdf'));
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.lessonPageContainer}>
      <View style={styles.lessonTopBar}>
        <Pressable onPress={onBack} style={styles.backButton}>
          <Text style={styles.backButtonText}>{tr('backToThemes')}</Text>
        </Pressable>
        <Pressable onPress={downloadLessonPdf} style={styles.downloadButton}>
          <Text style={styles.downloadButtonText}>{tr('downloadPdf')}</Text>
        </Pressable>
      </View>

      <Text style={[styles.classTitle, isSmall && styles.classTitleSmall]}>{lesson.title}</Text>
      <Text style={styles.lessonMetaText}>{tr('classLabel')}: {classNumber}</Text>
      <Text style={styles.lessonMetaText}>{tr('module')}: {moduleTitle}</Text>

      {availableSpecificFormats.length > 0 ? (
        <View style={styles.modeRow}>
          <Pressable
            onPress={() => setSelectedFormat('all')}
            style={[styles.modeButton, selectedFormat === 'all' && styles.modeButtonActive]}
          >
            <Text style={[styles.modeButtonText, selectedFormat === 'all' && styles.modeButtonTextActive]}>
              {formatLabel('all')}
            </Text>
          </Pressable>
          {availableSpecificFormats.map((format) => (
            <Pressable
              key={`format-${format}`}
              onPress={() => setSelectedFormat(format)}
              style={[styles.modeButton, selectedFormat === format && styles.modeButtonActive]}
            >
              <Text style={[styles.modeButtonText, selectedFormat === format && styles.modeButtonTextActive]}>
                {formatLabel(format)}
              </Text>
            </Pressable>
          ))}
        </View>
      ) : (
        <Text style={styles.lessonMetaText}>{formatLabel('all')}</Text>
      )}

      <View style={styles.modeRow}>
        <Pressable
          onPress={() => {
            setViewMode('all');
            setExerciseIndex(0);
          }}
          style={[styles.modeButton, viewMode === 'all' && styles.modeButtonActive]}
        >
          <Text style={[styles.modeButtonText, viewMode === 'all' && styles.modeButtonTextActive]}>
            {tr('seeAllExercises')}
          </Text>
        </Pressable>
        <Pressable
          onPress={() => {
            setViewMode('single');
            setExerciseIndex(0);
          }}
          style={[styles.modeButton, viewMode === 'single' && styles.modeButtonActive]}
        >
          <Text style={[styles.modeButtonText, viewMode === 'single' && styles.modeButtonTextActive]}>
            {tr('oneByOne')}
          </Text>
        </Pressable>
      </View>

      {viewMode === 'single' ? (
        <>
          <Text style={styles.counterText}>
            {filteredExercises.length === 0
              ? `0 / 0 ${tr('exercises').toLowerCase()}`
              : `${exerciseIndex + 1} / ${filteredExercises.length} ${tr('exercises').toLowerCase()}`}
          </Text>

          {singleExercise ? (
            <View style={styles.exerciseCard}>
              <Text style={styles.exerciseTitle}>{singleExercise.label}</Text>
              {renderExerciseContent(lesson, singleExercise, videoHeight)}
            </View>
          ) : (
            <Text style={styles.infoText}>{tr('noExercises')}</Text>
          )}

          <View style={styles.navRow}>
            <Pressable
              onPress={() => setExerciseIndex((prev) => Math.max(0, prev - 1))}
              style={[styles.navButton, exerciseIndex === 0 && styles.navButtonDisabled]}
              disabled={exerciseIndex === 0}
            >
              <Text style={styles.navButtonText}>{tr('prev')}</Text>
            </Pressable>
            <Pressable
              onPress={() => setExerciseIndex((prev) => Math.min(filteredExercises.length - 1, prev + 1))}
              style={[
                styles.navButton,
                (filteredExercises.length === 0 || exerciseIndex === filteredExercises.length - 1) &&
                  styles.navButtonDisabled
              ]}
              disabled={filteredExercises.length === 0 || exerciseIndex === filteredExercises.length - 1}
            >
              <Text style={styles.navButtonText}>{tr('next')}</Text>
            </Pressable>
          </View>
        </>
      ) : (
        <View style={styles.exerciseList}>
          {filteredExercises.length === 0 ? (
            <Text style={styles.infoText}>{tr('noExercises')}</Text>
          ) : (
            filteredExercises.map((exercise) => (
              <View key={exercise.id} style={styles.exerciseCard}>
                <Text style={styles.exerciseTitle}>{exercise.label}</Text>
                {renderExerciseContent(lesson, exercise, videoHeight)}
              </View>
            ))
          )}
        </View>
      )}

      {error ? <Text style={styles.errorText}>{error}</Text> : null}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
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
    fontSize: 20,
    fontWeight: '700'
  },
  classTitle: {
    alignSelf: 'center',
    color: '#0F172A',
    fontSize: 34,
    fontWeight: '800',
    marginTop: 12,
    textAlign: 'center'
  },
  classTitleSmall: {
    fontSize: 28
  },
  lessonMetaText: {
    color: '#334155',
    fontSize: 19,
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
    fontSize: 18,
    fontWeight: '700'
  },
  modeButtonTextActive: {
    color: '#FFFFFF'
  },
  counterText: {
    color: '#0F172A',
    fontSize: 20,
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
    fontSize: 23,
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
    overflow: 'hidden',
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
    fontSize: 17,
    fontWeight: '700'
  },
  exerciseText: {
    color: '#1E293B',
    fontSize: 19,
    lineHeight: 26,
    marginTop: 6
  },
  questionList: {
    marginTop: 4
  },
  flashcardCard: {
    backgroundColor: '#F8FAFC',
    borderRadius: 10,
    marginTop: 8,
    padding: 10
  },
  flashcardTitle: {
    color: '#1D4ED8',
    fontSize: 17,
    fontWeight: '800'
  },
  flashcardQuestion: {
    color: '#000000',
    fontSize: 20,
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
    fontSize: 17,
    fontWeight: '700',
    textAlign: 'center'
  },
  choiceSquareCorrect: {
    backgroundColor: '#86EFAC',
    borderColor: '#16A34A'
  },
  choiceSquareWrong: {
    backgroundColor: '#FCA5A5',
    borderColor: '#DC2626'
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
    fontSize: 17,
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
    fontSize: 18,
    fontWeight: '700'
  },
  tableWrap: {
    borderColor: '#CBD5E1',
    borderRadius: 8,
    borderWidth: 1,
    marginTop: 6,
    overflow: 'hidden'
  },
  tableHeaderRow: {
    backgroundColor: '#E2E8F0',
    flexDirection: 'row'
  },
  tableDataRow: {
    flexDirection: 'row'
  },
  tableCell: {
    borderColor: '#CBD5E1',
    borderRightWidth: 1,
    borderTopWidth: 1,
    flex: 1,
    minHeight: 42,
    paddingHorizontal: 6,
    paddingVertical: 6
  },
  tableHeaderCell: {
    backgroundColor: '#E2E8F0'
  },
  tableRowLabelCell: {
    backgroundColor: '#F8FAFC'
  },
  tableHeaderText: {
    color: '#0F172A',
    fontSize: 15,
    fontWeight: '700',
    textAlign: 'center'
  },
  tableRowLabelText: {
    color: '#334155',
    fontSize: 14,
    fontWeight: '700',
    textAlign: 'center'
  },
  tableDataText: {
    color: '#0F172A',
    fontSize: 14,
    textAlign: 'center'
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
