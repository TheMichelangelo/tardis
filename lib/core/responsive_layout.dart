import 'dart:math' as math;

import 'package:flutter/material.dart';

double readingScale(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(16) / 16;

EdgeInsets pagePadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final gutter = width < 600 ? 12.0 : 24.0;
  return EdgeInsets.symmetric(
    horizontal: math.max(gutter, (width - 1120 * readingScale(context)) / 2),
    vertical: 16,
  );
}

/// Tables keep readable cells and expose horizontal scrolling on small screens.
class ScrollableTable extends StatefulWidget {
  const ScrollableTable(
      {required this.minWidth, required this.child, super.key});
  final double minWidth;
  final Widget child;

  @override
  State<ScrollableTable> createState() => _ScrollableTableState();
}

class _ScrollableTableState extends State<ScrollableTable> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Scrollbar(
          controller: _controller,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 14),
            child: SizedBox(
              width: math.max(constraints.maxWidth, widget.minWidth),
              child: widget.child,
            ),
          ),
        ),
      );
    });
  }
}
