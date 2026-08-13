import 'package:flutter/material.dart';

import '../../core/localization.dart';
import '../../models.dart';
import '../../repository.dart';
import 'lesson_page.dart';
import 'widgets/lesson_card.dart';
import 'widgets/theme_tabs.dart';

class ClassPage extends StatefulWidget {
  const ClassPage(
    this.classNumber, {
    this.repository = const LessonRepository(),
    super.key,
  });

  final int classNumber;
  final LessonRepository repository;

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  late final Future<StemClass> _lessons = widget.repository.load(
    widget.classNumber,
  );
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.get('class')} ${widget.classNumber}'),
      ),
      body: FutureBuilder<StemClass>(
        future: _lessons,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _LoadError();
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tabs = ThemeTab.fromClass(snapshot.requireData);
          if (tabs.isEmpty) {
            return Center(child: Text(AppStrings.get('noThemes')));
          }

          final selectedIndex = _selectedIndex.clamp(0, tabs.length - 1);
          final selected = tabs[selectedIndex];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                AppStrings.get('module'),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              ThemeTabs(
                tabs: tabs,
                selectedIndex: selectedIndex,
                onSelected: (index) => setState(() => _selectedIndex = index),
              ),
              const SizedBox(height: 14),
              _ThemePanel(
                tab: selected,
                classNumber: widget.classNumber,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemePanel extends StatelessWidget {
  const _ThemePanel({required this.tab, required this.classNumber});

  final ThemeTab tab;
  final int classNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tab.color, width: 2),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tab.module.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          ...tab.theme.lessons.map(
            (lesson) => LessonCard(
              lesson: lesson,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => LessonPage(
                    classNumber: classNumber,
                    moduleTitle: tab.module.title,
                    lesson: lesson,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          AppStrings.get('loadError'),
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
