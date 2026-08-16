import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationStore {
  static const _key = 'lesson_builder_navigation_v1';

  Future<String?> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_key);
  }

  Future<void> save(String route) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, route);
  }
}

class PersistingNavigatorObserver extends NavigatorObserver {
  PersistingNavigatorObserver(this.store);

  final NavigationStore store;

  void _save(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) store.save(name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _save(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _save(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _save(previousRoute);
  }
}
