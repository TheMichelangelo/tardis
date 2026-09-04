import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MaterialCache {
  static const _baseUrl = String.fromEnvironment(
    'STEM_MATERIALS_URL',
    defaultValue: 'https://themichelangelo.github.io/tardis/',
  );

  static Uri remoteUri(String path) => Uri.parse(_baseUrl).resolve(path);

  static Future<File> _file(String path) async {
    final root = await getApplicationSupportDirectory();
    return File(p.joinAll([root.path, 'materials', ...path.split('/')]));
  }

  static Future<Uint8List> readBytes(String path) async {
    File? file;
    try {
      file = await _file(path);
      if (await file.exists()) return await file.readAsBytes();
    } catch (_) {
      // Platform storage is unavailable in unit tests.
    }
    Object? bundledError;
    try {
      return (await rootBundle.load(path)).buffer.asUint8List();
    } catch (error) {
      bundledError = error;
      // Large lesson files are intentionally not bundled in the APK.
    }
    throw bundledError;
  }

  static Future<String> readString(String path) async =>
      utf8.decode(await readBytes(path));

  static Future<void> download(String path) async {
    final response = await http.get(remoteUri(path));
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}', uri: remoteUri(path));
    }
    final file = await _file(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(response.bodyBytes, flush: true);
  }
}
