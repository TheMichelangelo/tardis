import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const pageBackground = Color(0xfff8fafc);
  static const border = Color(0xffe2e8f0);
  static const secondaryText = Color(0xff475569);
  static const link = Color(0xff1d4ed8);
  static const exerciseLabel = Color(0xff3730a3);

  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2563eb)),
    scaffoldBackgroundColor: pageBackground,
    useMaterial3: true,
    cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
    appBarTheme: const AppBarTheme(
      backgroundColor: pageBackground,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
  );
}
