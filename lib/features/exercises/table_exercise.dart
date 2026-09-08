import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/localization.dart';
import '../../core/responsive_layout.dart';

class TableExercise extends StatefulWidget {
  const TableExercise(
      {required this.columns,
      required this.rows,
      required this.values,
      super.key});
  final List<String> columns;
  final List<String> rows;

  /// Correct answers in row order, excluding prefilled row labels.
  final List<String> values;

  @override
  State<TableExercise> createState() => _TableExerciseState();
}

class _TableExerciseState extends State<TableExercise> {
  final Map<int, int> _answers = {};
  late final List<int> _order = List.generate(widget.values.length, (i) => i)
    ..shuffle(Random());
  int? _selected;
  bool _checked = false;

  void _place(int cell, int value) => setState(() {
        _answers.removeWhere((key, answer) => answer == value);
        _answers[cell] = value;
        _selected = null;
        _checked = false;
      });

  Widget _tile(int value, {bool feedback = false}) => Material(
        color: _selected == value
            ? const Color(0xffdbeafe)
            : const Color(0xfff1f5f9),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Color(0xff64748b))),
        child: InkWell(
          onTap: feedback
              ? null
              : () =>
                  setState(() => _selected = _selected == value ? null : value),
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(widget.values[value])),
        ),
      );

  Widget _draggable(int value) => Draggable<int>(
        data: value,
        feedback: SizedBox(width: 240, child: _tile(value, feedback: true)),
        childWhenDragging: Opacity(opacity: .3, child: _tile(value)),
        child: _tile(value),
      );

  Widget _cell(int index, String label) {
    if (index >= widget.values.length) return const SizedBox(height: 64);
    final value = _answers[index];
    final correct =
        value != null && widget.values[value] == widget.values[index];
    final color = !_checked
        ? null
        : correct
            ? const Color(0xffdcfce7)
            : const Color(0xfffee2e2);
    return DragTarget<int>(
      onAcceptWithDetails: (details) => _place(index, details.data),
      builder: (context, candidates, rejected) => Semantics(
        label: label,
        child: InkWell(
          key: ValueKey('table-cell-$index'),
          onTap: () {
            if (_selected != null) {
              _place(index, _selected!);
            } else if (value != null) {
              setState(() {
                _answers.remove(index);
                _checked = false;
              });
            }
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.all(10),
            color: candidates.isNotEmpty ? const Color(0xffdbeafe) : color,
            child: Row(children: [
              Expanded(
                  child: value == null
                      ? Text(AppStrings.get('tableEmpty'),
                          style: const TextStyle(color: Color(0xff64748b)))
                      : Text(widget.values[value])),
              if (_checked)
                Icon(correct ? Icons.check_circle : Icons.cancel,
                    color:
                        correct ? Colors.green.shade800 : Colors.red.shade800,
                    semanticLabel: correct ? '✓' : '✕'),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.columns.isEmpty) return const SizedBox.shrink();
    final labelsInFirstColumn = widget.rows.isNotEmpty &&
        widget.columns.length > 1 &&
        widget.values.length ==
            widget.rows.length * (widget.columns.length - 1);
    final answerColumns = widget.columns.length - (labelsInFirstColumn ? 1 : 0);
    final rowCount = widget.rows.isNotEmpty
        ? widget.rows.length
        : (widget.values.length / answerColumns).ceil();
    final headers = [
      if (widget.rows.isNotEmpty && !labelsInFirstColumn) '',
      ...widget.columns
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppStrings.get('tableHint')),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final value in _order)
          if (!_answers.containsValue(value)) _draggable(value),
      ]),
      const SizedBox(height: 12),
      FilledButton.icon(
          onPressed: () => setState(() => _checked = true),
          icon: const Icon(Icons.fact_check),
          label: Text(AppStrings.get('tableCheck'))),
      const SizedBox(height: 12),
      ScrollableTable(
        minWidth: headers.length * 170 * readingScale(context),
        child: Table(
          border: TableBorder.all(color: Theme.of(context).dividerColor),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
                decoration: const BoxDecoration(color: Color(0xfff1f5f9)),
                children: [
                  for (final header in headers)
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(header,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700))),
                ]),
            for (var row = 0; row < rowCount; row++)
              TableRow(children: [
                if (widget.rows.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(widget.rows[row])),
                for (var col = 0; col < answerColumns; col++)
                  _cell(row * answerColumns + col,
                      '${widget.rows.isNotEmpty ? widget.rows[row] : row + 1}, ${widget.columns[col + (labelsInFirstColumn ? 1 : 0)]}'),
              ]),
          ],
        ),
      ),
    ]);
  }
}
