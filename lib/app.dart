import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/localization.dart';
import 'features/auth/auth_controller.dart';
import 'features/home/home_page.dart';

class StemApp extends StatefulWidget {
  const StemApp({this.authController, super.key});

  final AuthController? authController;

  @override
  State<StemApp> createState() => _StemAppState();
}

class _StemAppState extends State<StemApp> {
  late final AuthController _authController =
      widget.authController ?? AuthController();
  late final bool _ownsController = widget.authController == null;

  @override
  void initState() {
    super.initState();
    _authController.initialize();
  }

  @override
  void dispose() {
    if (_ownsController) _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STEM Laboratory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedBuilder(
        animation: _authController,
        builder: (context, _) {
          if (_authController.isInitializing) {
            return Scaffold(
              body: Center(child: Text(AppStrings.get('loading'))),
            );
          }
          return HomePage(authController: _authController);
        },
      ),
    );
  }
}
