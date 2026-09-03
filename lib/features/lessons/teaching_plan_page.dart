import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization.dart';
import '../../core/reading_settings.dart';
import '../../core/responsive_layout.dart';
import '../../core/stem_background.dart';
import '../../data/material_cache.dart';
import '../../models.dart';

/// A reading view of the complete plan; downloads use the compiled source PDF.
class TeachingPlanPage extends StatefulWidget {
  const TeachingPlanPage(
      {required this.title, required this.exercise, super.key});

  final String title;
  final StemExercise exercise;

  @override
  State<TeachingPlanPage> createState() => _TeachingPlanPageState();
}

class _TeachingPlanPageState extends State<TeachingPlanPage> {
  late Future<List<Map<String, dynamic>>> _sections;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _sections = _load();
  }

  @override
  void didUpdateWidget(TeachingPlanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.text('planAsset') !=
        widget.exercise.text('planAsset')) {
      _sections = _load();
    }
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final raw = await rootBundle.loadString(widget.exercise.text('planAsset'));
    final document = jsonDecode(raw) as Map<String, dynamic>;
    return (document['sections'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      final attachment = widget.exercise.objectList('attachments').single;
      final path = attachment['path'] as String;
      final data = await MaterialCache.readBytes(path);
      await FilePicker.saveFile(
        fileName: path.split('/').last,
        bytes: data,
        mimeType: 'application/pdf',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('downloadDiagnosticError'))),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachment = widget.exercise.objectList('attachments').single;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: const [TextSizeButton()],
      ),
      body: StemBackgroundBody(
        child: SingleChildScrollView(
          padding: pagePadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: 1120 * readingScale(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(widget.exercise.text('text')),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _downloading ? null : _download,
                    child: Text(attachment['label'] as String),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _sections,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.get('loadPlanError')),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _sections = _load()),
                              child: Text(AppStrings.get('retry')),
                            ),
                          ],
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return SelectionArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final section in snapshot.data!)
                              _section(context, section),
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
    );
  }

  Widget _section(BuildContext context, Map<String, dynamic> section) {
    final weeks = (section['weeks'] as List?)?.cast<Map<String, dynamic>>();
    final rows = section['rows'] as List?;
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(section['title'] as String,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (section['text'] is String)
              Text(section['text'] as String,
                  style: const TextStyle(height: 1.6)),
            if (rows != null)
              ScrollableTable(
                minWidth: 540 * readingScale(context),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(4),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border:
                      TableBorder.all(color: Theme.of(context).dividerColor),
                  children: [
                    for (final row in [
                      ['Розділ', 'І сем.', 'ІІ сем.', 'Разом'],
                      ...rows,
                    ])
                      TableRow(children: [
                        for (final value in row as List)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(value as String),
                          ),
                      ]),
                  ],
                ),
              ),
            if (weeks != null)
              for (final week in weeks) ...[
                Text(
                  'Тиждень ${week['week']} • ${week['hours']} год • '
                  '${week['referenceLabel'] ?? 'Зошит'}: с. ${week['pages']}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                Text(week['module'] as String),
                Text(week['topic'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(week['activity'] as String,
                    style: const TextStyle(height: 1.5)),
                const SizedBox(height: 8),
                Text('Очікуваний результат: ${week['outcome']}',
                    style: const TextStyle(height: 1.5)),
                if (week != weeks.last) const Divider(height: 32),
              ],
          ],
        ),
      ),
    );
  }
}
