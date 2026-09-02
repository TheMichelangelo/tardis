import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'localization.dart';

enum ReadingSize {
  standard(1, 'textSizeStandard'),
  large(1.3, 'textSizeLarge'),
  projector(1.7, 'textSizeProjector');

  const ReadingSize(this.factor, this.labelKey);
  final double factor;
  final String labelKey;
}

class ReadingSettings extends ChangeNotifier {
  static const _key = 'stem_reading_size_v1';
  ReadingSize _size = ReadingSize.standard;
  ReadingSize get size => _size;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_key);
    _size =
        ReadingSize.values.where((size) => size.name == saved).firstOrNull ??
            ReadingSize.standard;
  }

  Future<void> select(ReadingSize size) async {
    if (_size == size) return;
    _size = size;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, size.name);
  }
}

/// Keeps the navigator and in-progress answers mounted while text changes.
class ReadingSettingsScope extends StatelessWidget {
  const ReadingSettingsScope({
    required this.settings,
    required this.child,
    super.key,
  });

  final ReadingSettings settings;
  final Widget child;

  static ReadingSettings? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ReadingSettingsProvider>()
      ?.notifier;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => _ReadingSettingsProvider(
        notifier: settings,
        child: MediaQuery(
          data: media.copyWith(
            textScaler:
                _ReadingTextScaler(media.textScaler, settings.size.factor),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ReadingSettingsProvider extends InheritedNotifier<ReadingSettings> {
  const _ReadingSettingsProvider(
      {required super.notifier, required super.child});
}

/// Composes with the device's accessibility scaling, including nonlinear scales.
class _ReadingTextScaler extends TextScaler {
  const _ReadingTextScaler(this.device, this.factor);
  final TextScaler device;
  final double factor;

  @override
  double scale(double fontSize) => device.scale(fontSize) * factor;

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is _ReadingTextScaler &&
      other.device == device &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(device, factor);
}

class TextSizeButton extends StatelessWidget {
  const TextSizeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = ReadingSettingsScope.maybeOf(context);
    if (settings == null) return const SizedBox.shrink();
    return PopupMenuButton<ReadingSize>(
      tooltip: AppStrings.get('textSize'),
      icon: const Icon(Icons.text_fields),
      onSelected: settings.select,
      itemBuilder: (context) => [
        for (final size in ReadingSize.values)
          PopupMenuItem(
            value: size,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(settings.size == size ? Icons.check : Icons.text_fields),
                  const SizedBox(width: 12),
                  Expanded(child: Text(AppStrings.get(size.labelKey))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
