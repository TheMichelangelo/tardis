import { Pressable, ScrollView, StyleSheet, Text } from 'react-native';
import { tr } from '../localization';
import { ClassLessonsFile, ClassNumber, LessonTemplate } from '../lib/types';
import { LessonBuilder } from './LessonBuilder';

type Props = {
  classNumber: ClassNumber;
  data: ClassLessonsFile | null;
  error: string;
  onBack: () => void;
  onOpenLesson: (template: LessonTemplate, moduleId: string, themeId: string) => void;
};

export function ClassPage({ classNumber, data, error, onBack, onOpenLesson }: Props) {
  return (
    <ScrollView contentContainerStyle={styles.classContainer}>
      <Pressable onPress={onBack} style={styles.backButton}>
        <Text style={styles.backButtonText}>{tr('back')}</Text>
      </Pressable>

      <Text style={styles.classTitle}>{tr('classLabel')} {classNumber}</Text>

      {data ? (
        <LessonBuilder key={`class-${classNumber}`} data={data} onOpenLesson={onOpenLesson} />
      ) : (
        <Text style={styles.infoText}>{tr('loadingClassData')}</Text>
      )}

      {error ? <Text style={styles.errorText}>{error}</Text> : null}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
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
    fontSize: 18,
    fontWeight: '700'
  },
  classTitle: {
    alignSelf: 'center',
    color: '#0F172A',
    fontSize: 32,
    fontWeight: '800',
    marginTop: 12,
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
