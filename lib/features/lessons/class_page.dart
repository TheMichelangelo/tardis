import 'package:flutter/material.dart';

import '../../core/app_assets.dart';
import '../../core/app_routes.dart';
import '../../core/localization.dart';
import '../../core/stem_background.dart';
import '../auth/auth_controller.dart';
import '../../models.dart';
import '../../repository.dart';
import 'widgets/lesson_card.dart';
import 'widgets/theme_tabs.dart';

class ClassPage extends StatefulWidget {
  const ClassPage(
    this.classNumber, {
    required this.repository,
    required this.authController,
    required this.language,
    super.key,
  });

  final int classNumber;
  final LessonRepository repository;
  final AuthController authController;
  final AppLanguage language;

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  late Future<StemClass> _lessons;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _lessons = widget.repository.load(
      widget.classNumber,
      language: widget.language,
    );
  }

  Future<void> _openProposal() async {
    await Navigator.pushNamed(
      context,
      AppRoutes.proposal(widget.classNumber),
    );
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.get('class')} ${widget.classNumber}'),
        actions: [
          if (widget.authController.isLoggedIn)
            TextButton.icon(
              onPressed: _openProposal,
              icon: const Icon(Icons.edit_note),
              label: Text(AppStrings.get('createProposal')),
            ),
        ],
      ),
      body: StemBackgroundBody(
        child: FutureBuilder<StemClass>(
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tab.theme.lessons
                .expand((lesson) => lesson.formats)
                .toSet()
                .map(
                  (format) => Chip(
                    backgroundColor: const Color(0xff0f172a),
                    labelStyle: const TextStyle(color: Colors.white),
                    label: Text(AppStrings.format(format)),
                  ),
                )
                .toList(),
          ),
          ...tab.theme.lessons.map(
            (lesson) => LessonCard(
              lesson: lesson,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.lesson(
                  classNumber: classNumber,
                  moduleId: tab.module.id,
                  lessonId: lesson.id,
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
