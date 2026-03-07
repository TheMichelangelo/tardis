import { useMemo, useState } from 'react';
import {
  Image,
  Pressable,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useWindowDimensions
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { LessonBuilder } from './src/components/LessonBuilder';
import { loadLessonsFileForClass } from './src/lib/storage';
import {
  ClassLessonsFile,
  ClassNumber,
  LessonExercise,
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

function STEMBackground() {
  return (
    <View style={styles.backgroundLayer} pointerEvents="none">
      <Image source={logoImage} style={styles.backgroundLogoFull} resizeMode="cover" />
      <Image source={logoImage} style={styles.backgroundLogoOverlay} resizeMode="contain" />

      <Text style={[styles.bgItem, styles.formulaOne]}>E = mc²</Text>
      <Text style={[styles.bgItem, styles.formulaTwo]}>πr²</Text>
      <Text style={[styles.bgItem, styles.formulaThree]}>∑(a+b)</Text>
      <Text style={[styles.bgItem, styles.formulaFour]}>x² + y² = z²</Text>
      <Text style={[styles.bgItem, styles.formulaFive]}>F = ma</Text>
      <Text style={[styles.bgItem, styles.formulaSix]}>a² + b² = c²</Text>
      <Text style={[styles.bgItem, styles.formulaSeven]}>V = I · R</Text>
      <Text style={[styles.bgItem, styles.formulaEight]}>A = πr²</Text>
      <Text style={[styles.bgItem, styles.formulaNine]}>Δx/Δt</Text>
      <Text style={[styles.bgItem, styles.formulaTen]}>∫ f(x)dx</Text>

      <Text style={[styles.bgItem, styles.rocketOne]}>🚀</Text>
      <Text style={[styles.bgItem, styles.rocketTwo]}>🚀</Text>
      <Text style={[styles.bgItem, styles.rocketThree]}>🚀</Text>
      <Text style={[styles.bgItem, styles.rocketFour]}>🚀</Text>
      <Text style={[styles.bgItem, styles.rocketFive]}>🚀</Text>

      <Text style={[styles.bgItem, styles.mechOne]}>⚙️</Text>
      <Text style={[styles.bgItem, styles.mechTwo]}>⚙️</Text>
      <Text style={[styles.bgItem, styles.mechThree]}>🔩</Text>
      <Text style={[styles.bgItem, styles.mechFour]}>⚙️</Text>
      <Text style={[styles.bgItem, styles.mechFive]}>🛠️</Text>
      <Text style={[styles.bgItem, styles.mechSix]}>🔧</Text>
      <Text style={[styles.bgItem, styles.mechSeven]}>⛓️</Text>
    </View>
  );
}

function resolveLessonExercises(lesson: LessonTemplate): LessonExercise[] {
  return lesson.exercises ?? lesson.exersices ?? [];
}

function renderExerciseContent(lesson: LessonTemplate, exercise: LessonExercise) {
  switch (exercise.type) {
    case 'diagram':
      return (
        <Text style={styles.exerciseText}>
          Diagram image: {`${lesson.id}/${exercise.id}`} (image file named by exercise id)
        </Text>
      );
    case 'rebus':
      return (
        <Text style={styles.exerciseText}>
          Rebus image: {`${lesson.id}/${exercise.id}`} (image file named by exercise id)
        </Text>
      );
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
      return <Text style={styles.exerciseText}>Watch on YouTube: {exercise.youtubeUrl}</Text>;
    case 'interactive_quiz':
      return (
        <View style={styles.exerciseBlock}>
          {exercise.questions.map((question, index) => (
            <View key={question.id} style={styles.quizCard}>
              <Text style={styles.quizTitle}>Flashcard {index + 1}</Text>
              <Text style={styles.exerciseText}>{question.question}</Text>
              <Text style={styles.exerciseText}>
                Single choice: {question.answerTypes.singleChoice.join(' | ')}
              </Text>
              <Text style={styles.exerciseText}>True/False: {question.answerTypes.trueFalse}</Text>
              <Text style={styles.exerciseText}>Short text: {question.answerTypes.shortText}</Text>
            </View>
          ))}
        </View>
      );
    default:
      return null;
  }
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

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar style="dark" />
      <STEMBackground />

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
          <Pressable
            onPress={() => goToClassThemes(screen.classNumber)}
            style={styles.backButton}
          >
            <Text style={styles.backButtonText}>Back to Themes</Text>
          </Pressable>

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
                      <Text style={styles.exerciseType}>Type: {singleExercise.type}</Text>
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
                        <Text style={styles.exerciseType}>Type: {exercise.type}</Text>
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
  backgroundLayer: {
    ...StyleSheet.absoluteFillObject,
    overflow: 'hidden'
  },
  backgroundLogoFull: {
    ...StyleSheet.absoluteFillObject,
    opacity: 0.08
  },
  backgroundLogoOverlay: {
    height: 700,
    left: '-10%',
    opacity: 0.08,
    position: 'absolute',
    top: '8%',
    width: 700
  },
  bgItem: {
    fontWeight: '800',
    position: 'absolute'
  },
  formulaOne: {
    color: '#F97316',
    fontSize: 24,
    left: 24,
    top: 140,
    transform: [{ rotate: '-8deg' }]
  },
  formulaTwo: {
    color: '#2563EB',
    fontSize: 28,
    right: 20,
    top: 220,
    transform: [{ rotate: '10deg' }]
  },
  formulaThree: {
    color: '#16A34A',
    fontSize: 24,
    left: 28,
    top: '62%'
  },
  formulaFour: {
    color: '#E11D48',
    fontSize: 20,
    right: 24,
    top: '72%'
  },
  formulaFive: {
    color: '#9333EA',
    fontSize: 22,
    right: 28,
    top: '12%',
    transform: [{ rotate: '-12deg' }]
  },
  formulaSix: {
    color: '#0EA5E9',
    fontSize: 19,
    left: 20,
    top: '46%',
    transform: [{ rotate: '9deg' }]
  },
  formulaSeven: {
    color: '#22C55E',
    fontSize: 21,
    right: 42,
    top: '52%',
    transform: [{ rotate: '-6deg' }]
  },
  formulaEight: {
    color: '#F59E0B',
    fontSize: 20,
    left: '52%',
    top: '30%',
    transform: [{ rotate: '8deg' }]
  },
  formulaNine: {
    color: '#EF4444',
    fontSize: 22,
    left: '62%',
    top: '84%'
  },
  formulaTen: {
    color: '#14B8A6',
    fontSize: 20,
    left: '12%',
    top: '88%',
    transform: [{ rotate: '-5deg' }]
  },
  rocketOne: {
    fontSize: 32,
    right: 52,
    top: 120,
    transform: [{ rotate: '18deg' }]
  },
  rocketTwo: {
    fontSize: 28,
    left: 44,
    top: '78%',
    transform: [{ rotate: '-25deg' }]
  },
  rocketThree: {
    fontSize: 30,
    left: '72%',
    top: '22%',
    transform: [{ rotate: '24deg' }]
  },
  rocketFour: {
    fontSize: 26,
    left: '18%',
    top: '34%',
    transform: [{ rotate: '-18deg' }]
  },
  rocketFive: {
    fontSize: 34,
    right: '16%',
    top: '86%',
    transform: [{ rotate: '10deg' }]
  },
  mechOne: {
    fontSize: 34,
    left: '48%',
    top: 88
  },
  mechTwo: {
    fontSize: 30,
    right: '34%',
    top: '56%'
  },
  mechThree: {
    fontSize: 26,
    left: '34%',
    top: '82%'
  },
  mechFour: {
    fontSize: 32,
    right: '8%',
    top: '42%'
  },
  mechFive: {
    fontSize: 28,
    left: '8%',
    top: '58%',
    transform: [{ rotate: '-15deg' }]
  },
  mechSix: {
    fontSize: 28,
    right: '40%',
    top: '70%',
    transform: [{ rotate: '20deg' }]
  },
  mechSeven: {
    fontSize: 22,
    left: '72%',
    top: '64%'
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
  backButton: {
    alignSelf: 'flex-start',
    backgroundColor: 'rgba(226,232,240,0.95)',
    borderRadius: 10,
    paddingHorizontal: 18,
    paddingVertical: 12
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
  exerciseType: {
    color: '#475569',
    fontSize: 12,
    fontWeight: '700',
    marginTop: 2,
    textTransform: 'uppercase'
  },
  exerciseBlock: {
    marginTop: 8
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
