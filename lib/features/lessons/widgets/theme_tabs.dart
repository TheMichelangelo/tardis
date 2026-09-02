import 'package:flutter/material.dart';

import '../../../core/parsing.dart';
import '../../../core/responsive_layout.dart';
import '../../../models.dart';

class ThemeTab {
  const ThemeTab({required this.module, required this.theme});

  final StemModule module;
  final StemTheme theme;

  Color get color => parseHexColor(theme.color);

  static List<ThemeTab> fromClass(StemClass stemClass) {
    return stemClass.modules
        .expand(
          (module) => module.themes.map(
            (theme) => ThemeTab(module: module, theme: theme),
          ),
        )
        .toList();
  }
}

class ThemeTabs extends StatelessWidget {
  const ThemeTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<ThemeTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final scale = readingScale(context);
      if (constraints.maxWidth / scale < 700) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: ValueKey(selectedIndex),
            title: Text(tabs[selectedIndex].module.title),
            children: [
              for (final (index, tab) in tabs.indexed)
                ListTile(
                  title: Text(tab.module.title),
                  selected: index == selectedIndex,
                  leading: Icon(index == selectedIndex
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off),
                  onTap: () => onSelected(index),
                ),
            ],
          ),
        );
      }
      final count = (constraints.maxWidth / (240 * scale)).floor().clamp(2, 4);
      final width = (constraints.maxWidth - (count - 1) * 10) / count;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final (index, tab) in tabs.indexed)
            SizedBox(
              width: width,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  backgroundColor: tab.color.withValues(
                    alpha: index == selectedIndex ? 1 : .6,
                  ),
                ),
                onPressed: () => onSelected(index),
                child: Text(tab.module.title, textAlign: TextAlign.center),
              ),
            ),
        ],
      );
    });
  }
}
