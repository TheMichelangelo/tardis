import 'dart:math';

import 'package:flutter/material.dart';

class StemBackground extends StatelessWidget {
  const StemBackground({super.key});

  static const _symbols = [
    'E = mc²',
    'F = ma',
    'v = s/t',
    'H₂O',
    'π ≈ 3.14',
    'P = UI',
    'STEM',
    '1010',
    'S + T',
    'E + M',
    'x² + y²',
    'a / b',
  ];
  static const _colors = [
    Color(0xfff97316),
    Color(0xff2563eb),
    Color(0xff16a34a),
    Color(0xffe11d48),
    Color(0xff9333ea),
    Color(0xff0f766e),
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: LayoutBuilder(builder: (context, constraints) {
          final random = Random(7305);
          return Stack(
            children: List.generate(28, (index) {
              final symbol = _symbols[index % _symbols.length];
              final left =
                  random.nextDouble() * max(1, constraints.maxWidth - 70);
              final top =
                  random.nextDouble() * max(1, constraints.maxHeight - 40);
              return Positioned(
                left: left,
                top: top,
                child: Transform.rotate(
                  angle: (random.nextDouble() - .5) * .7,
                  child: Opacity(
                    opacity: .10,
                    child: Text(
                      symbol,
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: _colors[index % _colors.length],
                        fontSize: symbol.length <= 2 ? 34 : 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

class StemBackgroundBody extends StatelessWidget {
  const StemBackgroundBody({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: StemBackground()),
        Positioned.fill(child: child),
      ],
    );
  }
}
