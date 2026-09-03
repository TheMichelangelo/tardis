import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class MaterialCache {
  static Uri remoteUri(String path) => Uri.base.resolve(path);

  static Future<Uint8List> readBytes(String path) async {
    try {
      return (await rootBundle.load(path)).buffer.asUint8List();
    } catch (_) {
      final response = await http.get(remoteUri(path));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      return response.bodyBytes;
    }
  }

  static Future<String> readString(String path) async =>
      String.fromCharCodes(await readBytes(path));

  static Future<void> download(String path) async => readBytes(path);
}
