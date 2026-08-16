import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'core/language_controller.dart';
import 'core/localization.dart';
import 'core/navigation_store.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/login_page.dart';
import 'features/home/home_page.dart';
import 'features/lessons/class_page.dart';
import 'features/lessons/lesson_route_page.dart';
import 'features/proposals/proposal_page.dart';
import 'repository.dart';

class StemApp extends StatefulWidget {
  const StemApp({this.authController, this.languageController, super.key});

  final AuthController? authController;
  final LanguageController? languageController;

  @override
  State<StemApp> createState() => _StemAppState();
}

class _StemAppState extends State<StemApp> {
  late final AuthController _authController =
      widget.authController ?? AuthController();
  late final LanguageController _languageController =
      widget.languageController ?? LanguageController();
  late final bool _ownsAuthController = widget.authController == null;
  late final bool _ownsLanguageController = widget.languageController == null;
  final _navigationStore = NavigationStore();
  final _repository = LessonRepository();
  late final Future<String> _initialization = _initialize();

  Future<String> _initialize() async {
    await Future.wait([
      _authController.initialize(),
      _languageController.initialize(),
    ]);
    final route = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    if (kIsWeb) {
      return route.isEmpty ? AppRoutes.home : route;
    }
    if (route.isNotEmpty && route != AppRoutes.home) return route;
    return await _navigationStore.load() ?? AppRoutes.home;
  }

  @override
  void dispose() {
    if (_ownsAuthController) _authController.dispose();
    if (_ownsLanguageController) _languageController.dispose();
    super.dispose();
  }

  Route<dynamic> _route(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? AppRoutes.home);
    Widget page;
    final classMatch = RegExp(r'^/class/(5|6)$').firstMatch(uri.path);
    final lessonMatch = RegExp(
      r'^/class/(5|6)/module/([^/]+)/lesson/([^/]+)$',
    ).firstMatch(uri.path);

    if (uri.path == AppRoutes.login) {
      page = LoginPage(controller: _authController);
    } else if (uri.path == '/propose') {
      final classNumber = int.tryParse(uri.queryParameters['class'] ?? '');
      if (classNumber != 5 && classNumber != 6) {
        page = HomePage(
          authController: _authController,
          languageController: _languageController,
        );
      } else if (!_authController.isLoggedIn) {
        page = LoginPage(controller: _authController);
      } else {
        page = ProposalPage(
          classNumber: classNumber!,
          repository: _repository,
          authController: _authController,
          language: _languageController.language,
        );
      }
    } else if (lessonMatch != null) {
      page = LessonRoutePage(
        classNumber: int.parse(lessonMatch.group(1)!),
        moduleId: Uri.decodeComponent(lessonMatch.group(2)!),
        lessonId: Uri.decodeComponent(lessonMatch.group(3)!),
        repository: _repository,
        authController: _authController,
        language: _languageController.language,
      );
    } else if (classMatch != null || uri.path == '/classes') {
      final legacyClass = int.tryParse(uri.queryParameters['class'] ?? '');
      final classNumber =
          classMatch == null ? legacyClass : int.parse(classMatch.group(1)!);
      page = ClassPage(
        classNumber == 5 || classNumber == 6 ? classNumber! : 5,
        repository: _repository,
        authController: _authController,
        language: _languageController.language,
      );
    } else {
      page = HomePage(
        authController: _authController,
        languageController: _languageController,
      );
    }

    return MaterialPageRoute<void>(
      settings: RouteSettings(name: settings.name ?? AppRoutes.home),
      builder: (_) => page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialization,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: Scaffold(
              body: Center(child: Text(AppStrings.get('loading'))),
            ),
          );
        }
        return AnimatedBuilder(
          animation: Listenable.merge([
            _authController,
            _languageController,
          ]),
          builder: (context, _) => MaterialApp(
            title: 'STEM Laboratory',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            initialRoute: snapshot.requireData,
            onGenerateRoute: _route,
            navigatorObservers: [
              PersistingNavigatorObserver(_navigationStore),
            ],
          ),
        );
      },
    );
  }
}
