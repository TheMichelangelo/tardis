import 'package:flutter/material.dart';

import '../../../core/parsing.dart';
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
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          return SizedBox(
            width: 230,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: tab.color.withValues(
                  alpha: index == selectedIndex ? 1 : .6,
                ),
              ),
              onPressed: () => onSelected(index),
              child: Text(tab.module.title, textAlign: TextAlign.center),
            ),
          );
        },
      ),
    );
  }
}
