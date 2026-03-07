import { useMemo, useState } from 'react';
import { SafeAreaView, StyleSheet } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { ClassPage } from './src/components/ClassPage';
import { HomePage } from './src/components/HomePage';
import { LessonPage } from './src/components/LessonPage';
import { RandomSTEMBackground } from './src/components/RandomSTEMBackground';
import { loadLessonsFileForClass } from './src/lib/storage';
import {
  ClassLessonsFile,
  ClassNumber,
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

export default function App() {
  const [screen, setScreen] = useState<ScreenState>({ name: 'home' });
  const [data, setData] = useState<ClassLessonsFile | null>(null);
  const [error, setError] = useState('');
  const [isLoadingClass, setIsLoadingClass] = useState(false);

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
      lesson
    };
  }, [data, screen]);

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar style="dark" />
      <RandomSTEMBackground logoSource={logoImage} />

      {screen.name === 'home' ? (
        <HomePage
          logoSource={logoImage}
          isLoadingClass={isLoadingClass}
          error={error}
          onOpenClass={openClass}
        />
      ) : null}

      {screen.name === 'class' ? (
        <ClassPage
          classNumber={screen.classNumber}
          data={data}
          error={error}
          onBack={goHome}
          onOpenLesson={openLesson}
        />
      ) : null}

      {screen.name === 'lesson' ? (
        lessonContext ? (
          <LessonPage
            classNumber={screen.classNumber}
            moduleTitle={lessonContext.module.title}
            themeTitle={lessonContext.theme.title}
            lesson={lessonContext.lesson}
            error={error}
            onBack={() => goToClassThemes(screen.classNumber)}
            onError={setError}
          />
        ) : (
          <ClassPage
            classNumber={screen.classNumber}
            data={data}
            error={error || 'Lesson not found in current data.'}
            onBack={goHome}
            onOpenLesson={openLesson}
          />
        )
      ) : null}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    backgroundColor: '#FFFFFF',
    flex: 1
  }
});
