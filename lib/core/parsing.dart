import 'package:flutter/material.dart';

Color parseHexColor(String value) {
  final hex = value.trim().replaceFirst('#', '');
  final normalized = hex.length == 6 ? 'ff$hex' : hex;
  final parsed = int.tryParse(normalized, radix: 16);
  return parsed == null ? Colors.blue : Color(parsed);
}
