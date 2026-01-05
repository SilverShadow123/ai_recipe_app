import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class LocalImageDatasource {
  Future<String> saveImage(String id, Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$id.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
