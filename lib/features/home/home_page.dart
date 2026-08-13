import 'package:flutter/material.dart';

import '../../core/app_assets.dart';
import '../../core/localization.dart';
import '../lessons/class_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
