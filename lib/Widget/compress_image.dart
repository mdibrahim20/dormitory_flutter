import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

Future<File> compressImage(File file) async {
  final originalBytes = await file.readAsBytes();
  final image = img.decodeImage(originalBytes);

  final resized = img.copyResize(image!, width: 1024);
  final tempDir = await getTemporaryDirectory();
  final compressedPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  return File(compressedPath)..writeAsBytesSync(img.encodeJpg(resized, quality: 85));
}
