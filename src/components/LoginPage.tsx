import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { tr } from '../localization';

type Props = {
  error: string;
  isSubmitting: boolean;
  onBack: () => void;
  onLogin: (email: string, password: string) => Promise<void>;
};

export function LoginPage({ error, isSubmitting, onBack, onLogin }: Props) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.topBar}>
        <Pressable onPress={onBack} style={styles.backButton}>
          <Text style={styles.backButtonText}>{tr('back')}</Text>
        </Pressable>
      </View>

      <View style={styles.card}>
        <Text style={styles.title}>{tr('login')}</Text>
        <Text style={styles.subtitle}>{tr('loginHint')}</Text>

        <Text style={styles.label}>{tr('email')}</Text>
        <TextInput
          autoCapitalize="none"
          keyboardType="email-address"
          onChangeText={setEmail}
          placeholder={tr('emailPlaceholder')}
          style={styles.input}
          value={email}
        />

        <Text style={styles.label}>{tr('password')}</Text>
        <TextInput
          onChangeText={setPassword}
          placeholder={tr('passwordPlaceholder')}
          secureTextEntry
          style={styles.input}
          value={password}
        />

        <Pressable
          disabled={isSubmitting}
          onPress={() => void onLogin(email, password)}
          style={[styles.loginButton, isSubmitting && styles.loginButtonDisabled]}
        >
          <Text style={styles.loginButtonText}>
            {isSubmitting ? tr('loading') : tr('login')}
          </Text>
        </Pressable>

        {error ? <Text style={styles.errorText}>{error}</Text> : null}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    flexGrow: 1,
    justifyContent: 'center',
    padding: 24
  },
  topBar: {
    left: 24,
    position: 'absolute',
    top: 24
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
  card: {
    backgroundColor: 'rgba(255,255,255,0.96)',
    borderColor: '#DBEAFE',
    borderRadius: 20,
    borderWidth: 1,
    maxWidth: 480,
    padding: 24,
    width: '100%'
  },
  title: {
    color: '#0F172A',
    fontSize: 30,
    fontWeight: '800'
  },
  subtitle: {
    color: '#475569',
    fontSize: 15,
    marginTop: 8
  },
  label: {
    color: '#0F172A',
    fontSize: 15,
    fontWeight: '700',
    marginTop: 18
  },
  input: {
    backgroundColor: '#FFFFFF',
    borderColor: '#CBD5E1',
    borderRadius: 12,
    borderWidth: 1,
    color: '#0F172A',
    fontSize: 16,
    marginTop: 8,
    paddingHorizontal: 14,
    paddingVertical: 12
  },
  loginButton: {
    alignItems: 'center',
    backgroundColor: '#1D4ED8',
    borderRadius: 12,
    marginTop: 24,
    paddingHorizontal: 18,
    paddingVertical: 14
  },
  loginButtonDisabled: {
    opacity: 0.7
  },
  loginButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '800'
  },
  errorText: {
    color: '#B91C1C',
    fontSize: 14,
    marginTop: 16,
    textAlign: 'center'
  }
});
