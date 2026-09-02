import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_assets.dart';
import '../../core/app_routes.dart';
import '../../core/language_controller.dart';
import '../../core/localization.dart';
import '../../core/reading_settings.dart';
import '../../core/responsive_layout.dart';
import '../../core/stem_background.dart';
import '../auth/auth_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.authController,
    required this.languageController,
    this.showAndroidDownload = kIsWeb,
    super.key,
  });

  final AuthController authController;
  final LanguageController languageController;
  final bool showAndroidDownload;

  Future<void> _openLogin(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.login);
  }

  Future<void> _downloadAndroidApp(BuildContext context) async {
    final apkUri = Uri.base.resolve('downloads/stem-laboratory.apk');
    final opened = await launchUrl(apkUri, webOnlyWindowName: '_blank');
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('downloadError'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: StemBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: AnimatedBuilder(
                    animation: authController,
                    builder: (context, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OverflowBar(
                          alignment: MainAxisAlignment.spaceBetween,
                          overflowAlignment: OverflowBarAlignment.start,
                          spacing: 12,
                          overflowSpacing: 8,
                          children: [
                            if (showAndroidDownload)
                              OutlinedButton.icon(
                                key: const Key('download-android-apk'),
                                onPressed: () => _downloadAndroidApp(context),
                                icon: const Icon(Icons.android),
                                label: Text(AppStrings.get('downloadAndroid')),
                              ),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const TextSizeButton(),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xff0f172a),
                                  ),
                                  onPressed: authController.isLoggedIn
                                      ? authController.logout
                                      : () => _openLogin(context),
                                  child: Text(AppStrings.get(
                                    authController.isLoggedIn
                                        ? 'logout'
                                        : 'login',
                                  )),
                                ),
                                Tooltip(
                                  message: AppStrings.get('language'),
                                  child: DropdownButton<AppLanguage>(
                                    value: languageController.language,
                                    items: const [
                                      DropdownMenuItem(
                                        value: AppLanguage.ukrainian,
                                        child: Text('UA'),
                                      ),
                                      DropdownMenuItem(
                                        value: AppLanguage.english,
                                        child: Text('EN'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        languageController.select(value);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (authController.user?.placeOfWork.isNotEmpty ??
                            false)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(authController.user!.placeOfWork),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final width = math.min(1200.0, constraints.maxWidth - 24);
                    final imageHeight =
                        math.min(width * 9 / 16, constraints.maxHeight * .6);
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: math.max(0, constraints.maxHeight - 24)),
                        child: Center(
                          child: SizedBox(
                            width: width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppAssets.logo,
                                  key: const Key('home-stem-image'),
                                  width: width,
                                  height: imageHeight,
                                  fit: BoxFit.contain,
                                  semanticLabel:
                                      'STEM: Science, Technology, Engineering, Mathematics',
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  AppStrings.get('choose'),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 24),
                                const Wrap(
                                  spacing: 22,
                                  runSpacing: 16,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _ClassButton(
                                        number: 5, color: Color(0xffff6b6b)),
                                    _ClassButton(
                                        number: 6, color: Color(0xff4d96ff)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassButton extends StatelessWidget {
  const _ClassButton({required this.number, required this.color});

  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 92 * readingScale(context),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
        ),
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.classPage(number),
        ),
        child: Text(
          '$number',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
