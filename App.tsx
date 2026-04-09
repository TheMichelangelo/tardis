import { useEffect, useMemo, useState } from 'react';
import { SafeAreaView, StyleSheet, Text, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { appConfig, getActiveWebBasePath } from './src/config/appConfig';
import { ClassPage } from './src/components/ClassPage';
import { HomePage } from './src/components/HomePage';
import { LessonPage } from './src/components/LessonPage';
import { LoginPage } from './src/components/LoginPage';
import { ProposalPage } from './src/components/ProposalPage';
import { RandomSTEMBackground } from './src/components/RandomSTEMBackground';
import { tr } from './src/localization';
import {
  authenticateUser,
  loadAuthSession,
  loadLessonsFileForClass,
  loadNavigationState,
  saveAuthSession,
  saveNavigationState
} from './src/lib/storage';
import {
  AuthUser,
  ClassLessonsFile,
  ClassNumber,
  LessonTemplate
} from './src/lib/types';

const logoImage = require('./src/data/stem_logo.jpeg');
type ScreenState =
  | { name: 'home' }
  | { name: 'login' }
  | { name: 'class'; classNumber: ClassNumber }
  | { name: 'proposal'; classNumber: ClassNumber }
  | {
      name: 'lesson';
      classNumber: ClassNumber;
      moduleId: string;
      themeId: string;
      lessonId: string;
    };

function isWeb() {
  return typeof window !== 'undefined';
}

function getWebPathDetails() {
  if (!isWeb()) {
    return {
      pathname: '/',
      searchParams: new URLSearchParams()
    };
  }

  const { pathname, search } = window.location;
  const webBasePath = getActiveWebBasePath();
  const normalizedPath =
    pathname === webBasePath
      ? '/'
      : webBasePath && pathname.startsWith(`${webBasePath}/`)
        ? pathname.slice(webBasePath.length)
        : pathname;

  return {
    pathname: normalizedPath || '/',
    searchParams: new URLSearchParams(search)
  };
}

function buildWebUrl(screen: ScreenState) {
  const prefix = getActiveWebBasePath();

  switch (screen.name) {
    case 'home':
      return prefix;
    case 'login':
      return `${prefix}/login`;
    case 'class':
      return `${prefix}/class/${screen.classNumber}`;
    case 'proposal':
      return `${prefix}/propose?class=${screen.classNumber}`;
    case 'lesson':
      return `${prefix}/class/${screen.classNumber}/module/${encodeURIComponent(screen.moduleId)}/lesson/${encodeURIComponent(screen.lessonId)}`;
    default:
      return prefix;
  }
}

async function resolveWebScreenFromUrl(
  savedUser: AuthUser | null
): Promise<{ screen: ScreenState; data: ClassLessonsFile | null } | null> {
  const { pathname, searchParams } = getWebPathDetails();
  const normalizedPath = pathname.replace(/\/+$/, '') || '/';

  if (normalizedPath === '/') {
    return {
      screen: { name: 'home' },
      data: null
    };
  }

  if (normalizedPath === '/login') {
    return {
      screen: { name: 'login' },
      data: null
    };
  }

  if (normalizedPath === '/classes') {
    const classParam = searchParams.get('class');
    const classNumber = classParam === '5' || classParam === '6' ? Number(classParam) as ClassNumber : null;
    if (!classNumber) {
      return {
        screen: { name: 'home' },
        data: null
      };
    }

    const classData = await loadLessonsFileForClass(classNumber, appConfig.currentLanguage);
    return {
      screen: { name: 'class', classNumber },
      data: classData
    };
  }

  const classMatch = normalizedPath.match(/^\/class\/(5|6)$/);
  if (classMatch) {
    const classNumber = Number(classMatch[1]) as ClassNumber;
    const classData = await loadLessonsFileForClass(classNumber, appConfig.currentLanguage);
    return {
      screen: { name: 'class', classNumber },
      data: classData
    };
  }

  if (normalizedPath === '/propose') {
    const classParam = searchParams.get('class');
    const classNumber = classParam === '5' || classParam === '6' ? Number(classParam) as ClassNumber : null;
    if (!classNumber) {
      return {
        screen: savedUser ? { name: 'home' } : { name: 'login' },
        data: null
      };
    }

    const classData = await loadLessonsFileForClass(classNumber, appConfig.currentLanguage);
    return {
      screen: savedUser ? { name: 'proposal', classNumber } : { name: 'login' },
      data: classData
    };
  }

  const lessonMatch = normalizedPath.match(/^\/class\/(5|6)\/module\/([^/]+)\/lesson\/([^/]+)$/);
  if (lessonMatch) {
    const classNumber = Number(lessonMatch[1]) as ClassNumber;
    const moduleId = decodeURIComponent(lessonMatch[2]);
    const lessonId = decodeURIComponent(lessonMatch[3]);
    const classData = await loadLessonsFileForClass(classNumber, appConfig.currentLanguage);
    const module = classData.modules.find((item) => item.id === moduleId);

    if (module) {
      for (const theme of module.themes) {
        const lesson = theme.lessons.find((item) => item.id === lessonId);
        if (!lesson) {
          continue;
        }

        return {
          screen: {
            name: 'lesson',
            classNumber,
            moduleId,
            themeId: theme.id,
            lessonId
          },
          data: classData
        };
      }
    }

    return {
      screen: { name: 'home' },
      data: null
    };
  }

  return {
    screen: { name: 'home' },
    data: null
  };
}

export default function App() {
  const [screen, setScreen] = useState<ScreenState>({ name: 'home' });
  const [data, setData] = useState<ClassLessonsFile | null>(null);
  const [authUser, setAuthUser] = useState<AuthUser | null>(null);
  const [error, setError] = useState('');
  const [loginError, setLoginError] = useState('');
  const [isLoadingClass, setIsLoadingClass] = useState(false);
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [isRestoringScreen, setIsRestoringScreen] = useState(true);

  useEffect(() => {
    let isActive = true;

    const restoreNavigation = async () => {
      try {
        const savedUser = await loadAuthSession();
        if (savedUser && isActive) {
          setAuthUser(savedUser);
        }

        if (isWeb()) {
          const routedState = await resolveWebScreenFromUrl(savedUser);
          if (routedState) {
            if (!isActive) {
              return;
            }

            setData(routedState.data);
            setScreen(routedState.screen);
            return;
          }
        }

        const savedScreen = await loadNavigationState<ScreenState>();
        if (!savedScreen) {
          return;
        }

        if (savedScreen.name === 'home' || savedScreen.name === 'login') {
          setScreen(savedScreen);
          return;
        }

        const classData = await loadLessonsFileForClass(savedScreen.classNumber, appConfig.currentLanguage);
        if (!isActive) {
          return;
        }

        setData(classData);
        setScreen(
          savedScreen.name === 'proposal' && !savedUser
            ? { name: 'class', classNumber: savedScreen.classNumber }
            : savedScreen
        );
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

  useEffect(() => {
    if (!isWeb() || isRestoringScreen) {
      return;
    }

    const nextUrl = buildWebUrl(screen);
    const currentUrl = `${window.location.pathname}${window.location.search}`;
    if (currentUrl !== nextUrl) {
      window.history.replaceState(null, '', nextUrl);
    }
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

  const openLogin = () => {
    setLoginError('');
    setError('');
    setScreen({ name: 'login' });
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
    if (!authUser) {
      openLogin();
      return;
    }

    setError('');
    setScreen({ name: 'proposal', classNumber });
  };

  const login = async (email: string, password: string) => {
    setIsLoggingIn(true);
    setLoginError('');

    try {
      const user = await authenticateUser(email, password);
      if (!user) {
        setLoginError(tr('invalidLoginCredentials'));
        return;
      }

      setAuthUser(user);
      await saveAuthSession(user);
      setScreen({ name: 'home' });
    } catch {
      setLoginError(tr('invalidLoginCredentials'));
    } finally {
      setIsLoggingIn(false);
    }
  };

  const logout = async () => {
    setAuthUser(null);
    setLoginError('');
    await saveAuthSession(null);
    if (screen.name === 'proposal') {
      setScreen({ name: 'home' });
    }
  };

  const goHome = () => {
    setScreen({ name: 'home' });
    setData(null);
    setError('');
    setLoginError('');
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
          isLoggedIn={Boolean(authUser)}
          isLoadingClass={isLoadingClass}
          placeOfWork={authUser?.placeOfWork ?? ''}
          error={error}
          onOpenLogin={openLogin}
          onLogout={() => void logout()}
          onOpenClass={openClass}
        />
      ) : null}

      {!isRestoringScreen && screen.name === 'login' ? (
        <LoginPage
          error={loginError}
          isSubmitting={isLoggingIn}
          onBack={goHome}
          onLogin={login}
        />
      ) : null}

      {!isRestoringScreen && screen.name === 'class' ? (
        <ClassPage
          classNumber={screen.classNumber}
          data={data}
          error={error}
          isLoggedIn={Boolean(authUser)}
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
            isLoggedIn={Boolean(authUser)}
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
