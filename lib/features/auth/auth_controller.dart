import 'package:flutter/foundation.dart';

import 'auth_models.dart';
import 'auth_repository.dart';
import 'auth_session_store.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    AuthRepository? repository,
    AuthSessionStore sessionStore = const AuthSessionStore(),
  })  : _repository = repository ?? AuthRepository(),
        _sessionStore = sessionStore;

  final AuthRepository _repository;
  final AuthSessionStore _sessionStore;

  AuthUser? _user;
  bool _isInitializing = true;
  bool _isLoggingIn = false;
  bool _hasLoginError = false;

  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isInitializing => _isInitializing;
  bool get isLoggingIn => _isLoggingIn;
  bool get hasLoginError => _hasLoginError;

  Future<void> initialize() async {
    try {
      _user = await _sessionStore.load();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  void clearLoginError() {
    if (!_hasLoginError) return;
    _hasLoginError = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (_isLoggingIn) return false;
    _isLoggingIn = true;
    _hasLoginError = false;
    notifyListeners();

    try {
      final authenticated = await _repository.authenticate(email, password);
      if (authenticated == null) {
        _hasLoginError = true;
        return false;
      }
      _user = authenticated;
      await _sessionStore.save(authenticated);
      return true;
    } catch (_) {
      _hasLoginError = true;
      return false;
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _hasLoginError = false;
    notifyListeners();
    await _sessionStore.save(null);
  }
}
