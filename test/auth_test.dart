import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/features/auth/auth_models.dart';
import 'package:stem_laboratory/features/auth/auth_repository.dart';
import 'package:stem_laboratory/features/auth/auth_session_store.dart';

void main() {
  group('teacher authentication', () {
    late AuthRepository repository;

    setUp(() {
      final usersJson = jsonEncode({
        'users': [
          {
            'id': 'teacher-1',
            'emailHash': BCrypt.hashpw(
              'teacher@example.com',
              BCrypt.gensalt(logRounds: 4),
            ),
            'passwordHash': BCrypt.hashpw(
              'secret-password',
              BCrypt.gensalt(logRounds: 4),
            ),
            'placeOfWork': 'STEM Laboratory',
          },
        ],
      });
      repository = AuthRepository(loadUsers: () async => usersJson);
    });

    test('normalizes credentials and returns the safe session user', () async {
      final user = await repository.authenticate(
        '  TEACHER@example.com ',
        ' secret-password ',
      );

      expect(user?.id, 'teacher-1');
      expect(user?.placeOfWork, 'STEM Laboratory');
    });

    test('rejects an incorrect password', () async {
      final user = await repository.authenticate(
        'teacher@example.com',
        'incorrect',
      );

      expect(user, isNull);
    });
  });

  group('teacher session', () {
    const store = AuthSessionStore();
    const user = AuthUser(id: 'teacher-1', placeOfWork: 'STEM Laboratory');

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('persists and restores the authenticated user', () async {
      await store.save(user);

      final restored = await store.load();
      expect(restored?.id, user.id);
      expect(restored?.placeOfWork, user.placeOfWork);
    });

    test('logout removes the stored session', () async {
      await store.save(user);
      await store.save(null);

      expect(await store.load(), isNull);
    });
  });
}
