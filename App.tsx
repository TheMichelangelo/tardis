import { useEffect, useMemo, useState } from 'react';
import { SafeAreaView, StyleSheet, Text, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { appConfig } from './src/config/appConfig';
import { ClassPage } from './src/components/ClassPage';
import { HomePage } from './src/components/HomePage';
import { LessonPage } from './src/components/LessonPage';
import { ProposalPage } from './src/components/ProposalPage';
import { RandomSTEMBackground } from './src/components/RandomSTEMBackground';
import { tr } from './src/localization';
import { loadLessonsFileForClass, loadNavigationState, saveNavigationState } from './src/lib/storage';
import {
  ClassLessonsFile,
  ClassNumber,
  LessonTemplate
} from './src/lib/types';

const logoImage = require('./src/data/stem_logo.jpeg');

type ScreenState =
  | { name: 'home' }
  | { name: 'class'; classNumber: ClassNumber }
  | { name: 'proposal'; classNumber: ClassNumber }
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
  const [isRestoringScreen, setIsRestoringScreen] = useState(true);

  useEffect(() => {
    let isActive = true;

    const restoreNavigation = async () => {
      try {
        const savedScreen = await loadNavigationState<ScreenState>();
        if (!savedScreen) {
          return;
        }

        if (savedScreen.name === 'home') {
          setScreen(savedScreen);
          return;
        }

        const classData = await loadLessonsFileForClass(savedScreen.classNumber, appConfig.currentLanguage);
        if (!isActive) {
          return;
        }

        setData(classData);
        setScreen(savedScreen);
      } catch {
        if (isActive) {
          setScreen({ name: 'home' });
          setData(null);
          setError('');
        }
      } finally {
        if (isActive) {
          setIsRestoringScreen(false);
        }
      }
    };

    void restoreNavigation();

    return () => {
      isActive = false;
    };
  }, []);

  useEffect(() => {
    if (isRestoringScreen) {
      return;
    }

    void saveNavigationState(screen);
  }, [isRestoringScreen, screen]);

  const openClass = async (classNumber: ClassNumber) => {
    setIsLoadingClass(true);
    setError('');

    try {
      const classData = await loadLessonsFileForClass(classNumber, appConfig.currentLanguage);
      setData(classData);
      setScreen({ name: 'class', classNumber });
    } catch {
      setError(tr('errorLoadClass'));
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

  const openProposal = (classNumber: ClassNumber) => {
    setError('');
    setScreen({ name: 'proposal', classNumber });
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

      {isRestoringScreen ? (
        <View style={styles.restoringContainer}>
          <Text style={styles.restoringText}>{tr('loading')}</Text>
        </View>
      ) : null}

      {!isRestoringScreen && screen.name === 'home' ? (
        <HomePage
          logoSource={logoImage}
          isLoadingClass={isLoadingClass}
          error={error}
          onOpenClass={openClass}
        />
      ) : null}

      {!isRestoringScreen && screen.name === 'class' ? (
        <ClassPage
          classNumber={screen.classNumber}
          data={data}
          error={error}
          onBack={goHome}
          onOpenLesson={openLesson}
          onOpenProposal={() => openProposal(screen.classNumber)}
        />
      ) : null}

      {!isRestoringScreen && screen.name === 'proposal' ? (
        <ProposalPage
          classNumber={screen.classNumber}
          data={data}
          onBack={() => goToClassThemes(screen.classNumber)}
        />
      ) : null}

      {!isRestoringScreen && screen.name === 'lesson' ? (
        lessonContext ? (
          <LessonPage
            classNumber={screen.classNumber}
            moduleTitle={lessonContext.module.title}
            lesson={lessonContext.lesson}
            error={error}
            onBack={() => goToClassThemes(screen.classNumber)}
            onError={setError}
          />
        ) : (
          <ClassPage
            classNumber={screen.classNumber}
            data={data}
            error={error || tr('errorLessonNotFound')}
            onBack={goHome}
            onOpenLesson={openLesson}
            onOpenProposal={() => openProposal(screen.classNumber)}
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
  },
  restoringContainer: {
    alignItems: 'center',
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 24
  },
  restoringText: {
    color: '#0F172A',
    fontSize: 18,
    fontWeight: '700',
    textAlign: 'center'
  }
});
