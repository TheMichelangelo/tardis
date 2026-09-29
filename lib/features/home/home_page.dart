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
import 'lesson_code_entry.dart';

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

  Future<void> _showLessonCodeDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(4),
            child: LessonCodeEntry(
              onOpenLesson: (code) {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamed(AppRoutes.sharedLesson(code));
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: languageController,
      builder: (context, _) => Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: _StemImageBackground()),
            // Keep the formulas above the STEM artwork, but behind controls.
            const Positioned.fill(child: StemBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, viewport) {
                  final compact = viewport.maxWidth < 640;
                  final hasPlaceOfWork =
                      authController.user?.placeOfWork.isNotEmpty ?? false;
                  final contentTop = hasPlaceOfWork
                      ? (compact ? 164.0 : 148.0)
                      : (compact ? 132.0 : 116.0);
                  return Stack(
                    children: [
                      if (showAndroidDownload)
                        Positioned(
                          top: 8,
                          left: 12,
                          child: _DownloadAndroidButton(
                            compact: compact,
                            onPressed: () => _downloadAndroidApp(context),
                          ),
                        ),
                      Positioned(
                        top: compact ? 60 : 8,
                        right: 12,
                        child: AnimatedBuilder(
                          animation: authController,
                          builder: (context, _) => Wrap(
                            spacing: 8,
                            runSpacing: 4,
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
                        ),
                      ),
                      if (hasPlaceOfWork)
                        Positioned(
                          top: compact ? 124 : 116,
                          left: 12,
                          right: 12,
                          child: Text(authController.user!.placeOfWork),
                        ),
                      Positioned.fill(
                        top: contentTop,
                        child: LayoutBuilder(builder: (context, constraints) {
                          final width =
                              math.min(680.0, constraints.maxWidth - 24);
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    math.max(0, constraints.maxHeight - 40),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: width,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: .82),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: .8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 28,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            AppStrings.get('choose'),
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          const SizedBox(height: 24),
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              final optionRowWidth = math.min(
                                                constraints.maxWidth,
                                                3 * 92 * readingScale(context) +
                                                    44,
                                              );
                                              return SizedBox(
                                                width: optionRowWidth,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    const Wrap(
                                                      spacing: 22,
                                                      runSpacing: 16,
                                                      alignment:
                                                          WrapAlignment.center,
                                                      children: [
                                                        _ClassButton(
                                                          number: 5,
                                                          color:
                                                              Color(0xffff6b6b),
                                                        ),
                                                        _ClassButton(
                                                          number: 6,
                                                          color:
                                                              Color(0xff4d96ff),
                                                        ),
                                                        _ClassButton(
                                                          number: 7,
                                                          color:
                                                              Color(0xff16a34a),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 20),
                                                    FilledButton.icon(
                                                      key: const Key(
                                                        'show-lesson-code-dialog',
                                                      ),
                                                      onPressed: () =>
                                                          _showLessonCodeDialog(
                                                              context),
                                                      icon:
                                                          const Icon(Icons.key),
                                                      label:
                                                          Text(AppStrings.get(
                                                        'openByCode',
                                                      )),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StemImageBackground extends StatelessWidget {
  const _StemImageBackground();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Image.asset(
          AppAssets.logo,
          key: const Key('home-stem-image'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      );
}

class _DownloadAndroidButton extends StatelessWidget {
  const _DownloadAndroidButton(
      {required this.compact, required this.onPressed});

  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: AppStrings.get('downloadAndroid'),
        child: OutlinedButton.icon(
          key: const Key('download-android-apk'),
          onPressed: onPressed,
          icon: const Icon(Icons.android),
          label: compact
              ? const SizedBox.shrink()
              : Text(AppStrings.get('downloadAndroid')),
          style: compact
              ? OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                )
              : null,
        ),
      );
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
