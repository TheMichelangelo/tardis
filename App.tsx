import { useState } from 'react';
import {
  Image,
  Pressable,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  View
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { LessonBuilder } from './src/components/LessonBuilder';
import { generateLessonFromTemplate } from './src/lib/lessonFormatter';
import { loadLessonsFileForClass, saveLessonsFileForClass } from './src/lib/storage';
import {
  ClassLessonsFile,
  ClassNumber,
  LessonTemplate,
  LessonType
} from './src/lib/types';

const logoImage = require('./src/data/stem_logo.jpeg');

type ScreenState =
  | { name: 'home' }
  | { name: 'class'; classNumber: ClassNumber };

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

export default function App() {
  const [screen, setScreen] = useState<ScreenState>({ name: 'home' });
  const [data, setData] = useState<ClassLessonsFile | null>(null);
  const [message, setMessage] = useState('');
  const [isLoadingClass, setIsLoadingClass] = useState(false);

  const openClass = async (classNumber: ClassNumber) => {
    setIsLoadingClass(true);
    setMessage('');

    try {
      const classData = await loadLessonsFileForClass(classNumber);
      setData(classData);
      setScreen({ name: 'class', classNumber });
    } catch {
      setMessage('Failed to load class lessons JSON.');
    } finally {
      setIsLoadingClass(false);
    }
  };

  const handleSaveLesson = async (
    template: LessonTemplate,
    type: LessonType,
    moduleId: string,
    themeId: string
  ) => {
    if (screen.name !== 'class' || !data) {
      return;
    }

    const lesson = generateLessonFromTemplate(
      template,
      type,
      new Date().toISOString(),
      screen.classNumber,
      moduleId,
      themeId
    );

    const updated: ClassLessonsFile = {
      ...data,
      lessons: [lesson, ...data.lessons]
    };

    await saveLessonsFileForClass(screen.classNumber, updated);
    setData(updated);
    setMessage(`Saved for class ${screen.classNumber}: ${lesson.title}`);
  };

  const goHome = () => {
    setScreen({ name: 'home' });
    setData(null);
    setMessage('');
  };

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
          {message ? <Text style={styles.errorText}>{message}</Text> : null}
        </ScrollView>
      ) : (
        <ScrollView contentContainerStyle={styles.classContainer}>
          <Pressable onPress={goHome} style={styles.backButton}>
            <Text style={styles.backButtonText}>Back</Text>
          </Pressable>

          <Text style={styles.classTitle}>Class {screen.classNumber}</Text>

          {data ? (
            <>
              <LessonBuilder
                key={`class-${screen.classNumber}`}
                data={data}
                onSaveLesson={handleSaveLesson}
              />
            </>
          ) : (
            <Text style={styles.infoText}>Loading class data...</Text>
          )}

          {message ? <Text style={styles.successText}>{message}</Text> : null}
        </ScrollView>
      )}
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
  infoText: {
    color: '#475569',
    fontSize: 14,
    marginTop: 12
  },
  errorText: {
    color: '#B91C1C',
    fontSize: 14,
    marginTop: 12
  },
  successText: {
    color: '#14532D',
    fontSize: 14,
    fontWeight: '600',
    marginTop: 8
  }
});
