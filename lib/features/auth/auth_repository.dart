import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/services.dart';

import '../../core/app_assets.dart';
import 'auth_models.dart';

typedef UserDataLoader = Future<String> Function();

class AuthRepository {
  AuthRepository({UserDataLoader? loadUsers})
      : _loadUsers =
            loadUsers ?? (() => rootBundle.loadString(AppAssets.users));

  final UserDataLoader _loadUsers;

  Future<AuthUser?> authenticate(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();
    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) return null;

    final users = await _readUsers();
    for (final user in users) {
      if (!_matches(normalizedEmail, user.emailHash)) continue;
      if (!_matches(normalizedPassword, user.passwordHash)) return null;
      return AuthUser(id: user.id, placeOfWork: user.placeOfWork);
    }
    return null;
  }

  Future<List<StoredUser>> _readUsers() async {
    final decoded = jsonDecode(await _loadUsers());
    if (decoded is! Map<String, dynamic>) return const [];
    final rawUsers = decoded['users'];
    if (rawUsers is! List) return const [];
    return rawUsers
        .whereType<Map<String, dynamic>>()
        .map(StoredUser.fromJson)
        .toList();
  }

  bool _matches(String value, String hash) {
    if (hash.isEmpty) return false;
    try {
      return BCrypt.checkpw(value, hash);
    } on ArgumentError {
      return false;
    }
  }
}
