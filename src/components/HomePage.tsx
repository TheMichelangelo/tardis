import { Image, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { tr } from '../localization';
import { ClassNumber } from '../lib/types';

type Props = {
  logoSource: number;
  isLoadingClass: boolean;
  error: string;
  onOpenClass: (classNumber: ClassNumber) => void;
};

const classButtonColors: Record<ClassNumber, string> = {
  5: '#FF6B6B',
  6: '#4D96FF'
};

export function HomePage({ logoSource, isLoadingClass, error, onOpenClass }: Props) {
  return (
    <ScrollView contentContainerStyle={styles.homeContainer}>
      <Image source={logoSource} style={styles.logo} resizeMode="contain" />
      <Text style={styles.pageTitle}>{tr('chooseClassWithLessons')}</Text>
      <View style={styles.classButtonRow}>
        <Pressable
          style={[styles.classButton, { backgroundColor: classButtonColors[5] }]}
          onPress={() => onOpenClass(5)}
        >
          <Text style={styles.classButtonText}>5</Text>
        </Pressable>
        <Pressable
          style={[styles.classButton, { backgroundColor: classButtonColors[6] }]}
          onPress={() => onOpenClass(6)}
        >
          <Text style={styles.classButtonText}>6</Text>
        </Pressable>
      </View>

      {isLoadingClass ? <Text style={styles.infoText}>{tr('loading')}</Text> : null}
      {error ? <Text style={styles.errorText}>{error}</Text> : null}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
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
  pageTitle: {
    color: '#0F172A',
    fontSize: 34,
    fontWeight: '800',
    marginBottom: 8,
    textAlign: 'center'
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
