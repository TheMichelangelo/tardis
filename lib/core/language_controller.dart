import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_assets.dart';
import 'localization.dart';

class LanguageController extends ChangeNotifier {
  static const _key = 'stem_language_v1';

  AppLanguage _language = AppLanguage.ukrainian;
  AppLanguage get language => _language;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final code = preferences.getString(_key);
    _language = code == AppLanguage.english.code
        ? AppLanguage.english
        : AppLanguage.ukrainian;
    AppStrings.setLanguage(_language);
  }

  Future<void> select(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    AppStrings.setLanguage(language);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, language.code);
  }
}
