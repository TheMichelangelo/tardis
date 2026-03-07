import { useEffect, useMemo, useState } from 'react';
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useWindowDimensions
} from 'react-native';
import {
  ClassLessonsFile,
  LessonExercise,
  LessonTemplate,
  LessonType,
  Theme
} from '../lib/types';

type ThemeTab = {
  moduleId: string;
  moduleTitle: string;
  theme: Theme;
};

type Props = {
  data: ClassLessonsFile;
  onSaveLesson: (
    template: LessonTemplate,
    type: LessonType,
    moduleId: string,
    themeId: string
  ) => Promise<void>;
};

function normalizeTypeLabel(type: LessonType) {
  if (type === 'flashcards') {
    return 'Flashcards';
  }
  return type[0].toUpperCase() + type.slice(1);
}

function normalizeExerciseTypeLabel(type: LessonExercise['type']) {
  return type.replace('_', ' ');
}

function resolveLessonExercises(lesson: LessonTemplate): LessonExercise[] {
  return lesson.exercises ?? lesson.exersices ?? [];
}

export function LessonBuilder({ data, onSaveLesson }: Props) {
  const { width, height } = useWindowDimensions();
  const [selectedThemeKey, setSelectedThemeKey] = useState<string>('');
  const [isSaving, setIsSaving] = useState(false);
  const tabWidth = Math.max(130, Math.min(320, Math.round(width * 0.24)));
  const moduleFontSize = Math.max(10, Math.min(13, Math.round(width * 0.012)));
  const themeFontSize = Math.max(14, Math.min(22, Math.round(width * 0.02)));
  const lessonsMaxHeight = Math.max(220, Math.round(height * 0.5));

  const themeTabs = useMemo<ThemeTab[]>(() => {
    return data.modules.flatMap((module) =>
      module.themes.map((theme) => ({
        moduleId: module.id,
        moduleTitle: module.title,
        theme
      }))
    );
  }, [data.modules]);

  useEffect(() => {
    if (themeTabs[0]) {
      setSelectedThemeKey(`${themeTabs[0].moduleId}:${themeTabs[0].theme.id}`);
      return;
    }
    setSelectedThemeKey('');
  }, [themeTabs]);

  const selectedTab = themeTabs.find(
    (tab) => `${tab.moduleId}:${tab.theme.id}` === selectedThemeKey
  );

  const handleCreateLesson = async (template: LessonTemplate, type: LessonType) => {
    if (!selectedTab || isSaving) {
      return;
    }

    setIsSaving(true);
    try {
      await onSaveLesson(template, type, selectedTab.moduleId, selectedTab.theme.id);
    } finally {
      setIsSaving(false);
    }
  };

  const selectedThemeFormats = selectedTab
    ? Array.from(new Set(selectedTab.theme.lessons.flatMap((lesson) => lesson.formats)))
    : [];

  if (themeTabs.length === 0) {
    return <Text style={styles.errorText}>No themes found in class config.</Text>;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>Themes</Text>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.tabsRow}>
        {themeTabs.map((tab) => {
          const tabKey = `${tab.moduleId}:${tab.theme.id}`;
          const active = tabKey === selectedThemeKey;
          return (
            <Pressable
              key={tabKey}
              onPress={() => setSelectedThemeKey(tabKey)}
              style={[
                styles.tabButton,
                { width: tabWidth },
                { backgroundColor: tab.theme.color },
                active && styles.tabButtonActive
              ]}
            >
              <Text style={[styles.tabModuleText, { fontSize: moduleFontSize }]}>
                {tab.moduleTitle}
              </Text>
              <Text style={[styles.tabThemeText, { fontSize: themeFontSize }]}>
                {tab.theme.title}
              </Text>
            </Pressable>
          );
        })}
      </ScrollView>

      {selectedTab ? (
        <View style={[styles.themePanel, { borderColor: selectedTab.theme.color }]}> 
          <Text style={styles.themeTitle}>{selectedTab.theme.title}</Text>
          <Text style={styles.moduleText}>Module: {selectedTab.moduleTitle}</Text>
          <View style={styles.labelsRow}>
            {selectedThemeFormats.map((format) => (
              <View key={`theme-format-${format}`} style={styles.themeFormatLabel}>
                <Text style={styles.themeFormatLabelText}>{normalizeTypeLabel(format)}</Text>
              </View>
            ))}
          </View>

          <ScrollView
            nestedScrollEnabled
            style={{ maxHeight: lessonsMaxHeight }}
            contentContainerStyle={styles.lessonsList}
            showsVerticalScrollIndicator
          >
            {selectedTab.theme.lessons.map((lesson) => (
              <View key={lesson.id} style={styles.lessonCard}>
                <Text style={styles.lessonTitle}>{lesson.title}</Text>
                <Text style={styles.lessonTopic}>Topic: {lesson.topic}</Text>
                <Text style={styles.lessonTopic}>
                  Exercises: {resolveLessonExercises(lesson).length}
                </Text>

                <View style={styles.labelsRow}>
                  {lesson.formats.map((format) => (
                    <View key={`${lesson.id}-${format}`} style={styles.formatLabel}>
                      <Text style={styles.formatLabelText}>{normalizeTypeLabel(format)}</Text>
                    </View>
                  ))}
                </View>

                <View style={styles.labelsRow}>
                  {resolveLessonExercises(lesson).map((exercise) => (
                    <View key={`${lesson.id}-${exercise.id}`} style={styles.exerciseTypeLabel}>
                      <Text style={styles.exerciseTypeLabelText}>
                        {normalizeExerciseTypeLabel(exercise.type)}
                      </Text>
                    </View>
                  ))}
                </View>

                <View style={styles.actionsRow}>
                  {lesson.formats.map((format) => (
                    <Pressable
                      key={`create-${lesson.id}-${format}`}
                      style={[styles.createButton, { backgroundColor: selectedTab.theme.color }]}
                      onPress={() => handleCreateLesson(lesson, format)}
                      disabled={isSaving}
                    >
                      <Text style={styles.createButtonText}>
                        {isSaving ? 'Saving...' : `Create ${normalizeTypeLabel(format)}`}
                      </Text>
                    </Pressable>
                  ))}
                </View>
              </View>
            ))}
          </ScrollView>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    gap: 6,
    paddingBottom: 16,
    paddingTop: 12
  },
  heading: {
    color: '#0F172A',
    fontSize: 24,
    fontWeight: '800'
  },
  tabsRow: {
    gap: 10,
    paddingVertical: 2
  },
  tabButton: {
    borderRadius: 16,
    minHeight: 78,
    opacity: 0.6,
    paddingHorizontal: 14,
    paddingVertical: 10
  },
  tabButtonActive: {
    opacity: 1,
    transform: [{ scale: 1.02 }]
  },
  tabModuleText: {
    color: '#FFFFFF',
    fontWeight: '700',
    textTransform: 'uppercase'
  },
  tabThemeText: {
    color: '#FFFFFF',
    fontWeight: '800',
    marginTop: 6
  },
  themePanel: {
    backgroundColor: 'rgba(255,255,255,0.94)',
    borderRadius: 14,
    borderWidth: 2,
    padding: 14
  },
  themeTitle: {
    color: '#0F172A',
    fontSize: 22,
    fontWeight: '800'
  },
  moduleText: {
    color: '#475569',
    fontSize: 13,
    marginTop: 2
  },
  lessonsList: {
    paddingBottom: 4
  },
  lessonCard: {
    backgroundColor: '#FFFFFF',
    borderColor: '#E2E8F0',
    borderRadius: 12,
    borderWidth: 1,
    marginTop: 10,
    padding: 12
  },
  lessonTitle: {
    color: '#0F172A',
    fontSize: 16,
    fontWeight: '700'
  },
  lessonTopic: {
    color: '#475569',
    fontSize: 13,
    marginTop: 2
  },
  labelsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 8
  },
  formatLabel: {
    backgroundColor: '#F1F5F9',
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 4
  },
  formatLabelText: {
    color: '#334155',
    fontSize: 12,
    fontWeight: '700'
  },
  themeFormatLabel: {
    backgroundColor: '#0F172A',
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 4
  },
  themeFormatLabelText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '700'
  },
  exerciseTypeLabel: {
    backgroundColor: '#EEF2FF',
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 4
  },
  exerciseTypeLabelText: {
    color: '#3730A3',
    fontSize: 12,
    fontWeight: '700'
  },
  actionsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 10
  },
  createButton: {
    borderRadius: 8,
    paddingHorizontal: 10,
    paddingVertical: 8
  },
  createButtonText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '700'
  },
  errorText: {
    color: '#B91C1C',
    fontSize: 16,
    paddingVertical: 12
  }
});
