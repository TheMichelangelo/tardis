import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_assets.dart';
import '../../core/localization.dart';
import '../auth/auth_controller.dart';
import '../auth/login_page.dart';
import '../lessons/class_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.authController, super.key});

  final AuthController authController;

  Future<void> _openLogin(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(controller: authController),
      ),
    );
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: authController,
                    builder: (context, _) => Row(
                      children: [
                        Expanded(
                          child: Text(
                            authController.user?.placeOfWork ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff0f172a),
                          ),
                          onPressed: authController.isLoggedIn
                              ? authController.logout
                              : () => _openLogin(context),
                          child: Text(
                            AppStrings.get(
                              authController.isLoggedIn ? 'logout' : 'login',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    AppAssets.logo,
                    height: 430,
                    fit: BoxFit.contain,
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
                        number: 5,
                        color: Color(0xffff6b6b),
                      ),
                      _ClassButton(
                        number: 6,
                        color: Color(0xff4d96ff),
                      ),
                    ],
                  ),
                  if (kIsWeb) ...[
                    const SizedBox(height: 28),
                    OutlinedButton.icon(
                      key: const Key('download-android-apk'),
                      onPressed: () => _downloadAndroidApp(context),
                      icon: const Icon(Icons.android),
                      label: Text(AppStrings.get('downloadAndroid')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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
      dimension: 92,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => ClassPage(number)),
        ),
        child: Text(
          '$number',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
