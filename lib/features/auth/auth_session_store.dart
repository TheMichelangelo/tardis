import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_models.dart';

class AuthSessionStore {
  const AuthSessionStore();

  static const _sessionKey = 'lesson_builder_auth_session_v1';

  Future<AuthUser?> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_sessionKey);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final user = AuthUser.fromJson(decoded);
      return user.id.isEmpty ? null : user;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(AuthUser? user) async {
    final preferences = await SharedPreferences.getInstance();
    if (user == null) {
      await preferences.remove(_sessionKey);
      return;
    }
    await preferences.setString(_sessionKey, jsonEncode(user.toJson()));
  }
}
