import { Image, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { tr } from '../localization';
import { ClassNumber } from '../lib/types';

type Props = {
  logoSource: number;
  isLoggedIn: boolean;
  isLoadingClass: boolean;
  placeOfWork: string;
  error: string;
  onOpenLogin: () => void;
  onLogout: () => void;
  onOpenClass: (classNumber: ClassNumber) => void;
};

const classButtonColors: Record<ClassNumber, string> = {
  5: '#FF6B6B',
  6: '#4D96FF'
};

export function HomePage({
  logoSource,
  isLoggedIn,
  isLoadingClass,
  placeOfWork,
  error,
  onOpenLogin,
  onLogout,
  onOpenClass
}: Props) {
  return (
    <ScrollView contentContainerStyle={styles.homeContainer}>
      <View style={styles.topBar}>
        {isLoggedIn ? <Text style={styles.workplaceText}>{placeOfWork}</Text> : <View />}
        <Pressable onPress={isLoggedIn ? onLogout : onOpenLogin} style={styles.loginButton}>
          <Text style={styles.loginButtonText}>{tr(isLoggedIn ? 'logout' : 'login')}</Text>
        </Pressable>
      </View>
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
    alignItems: 'stretch',
    gap: 10,
    paddingBottom: 40,
    paddingHorizontal: 24,
    paddingTop: 28
  },
  topBar: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    minHeight: 48
  },
  workplaceText: {
    color: '#334155',
    flex: 1,
    fontSize: 14,
    fontWeight: '600',
    paddingRight: 12
  },
  loginButton: {
    alignSelf: 'flex-end',
    backgroundColor: '#0F172A',
    borderRadius: 10,
    paddingHorizontal: 16,
    paddingVertical: 10
  },
  loginButtonText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '700'
  },
  logo: {
    alignSelf: 'center',
    height: 560,
    marginBottom: 16,
    maxWidth: 1040,
    width: '100%'
  },
  classButtonRow: {
    alignSelf: 'center',
    flexDirection: 'row',
    gap: 20,
    marginBottom: 8
  },
  pageTitle: {
    alignSelf: 'center',
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
    alignSelf: 'center',
    color: '#475569',
    fontSize: 14,
    marginTop: 12,
    textAlign: 'center'
  },
  errorText: {
    alignSelf: 'center',
    color: '#B91C1C',
    fontSize: 14,
    marginTop: 12,
    textAlign: 'center'
  }
});
