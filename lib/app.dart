import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/home/home_page.dart';

class StemApp extends StatelessWidget {
  const StemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STEM Laboratory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}
