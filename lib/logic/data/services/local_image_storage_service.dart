import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalImageStorageService {
  Future<String> storeImage(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(sourcePath);
    final filename = file.path.split(Platform.pathSeparator).last;
    final extension = filename.split('.').last;
    final targetName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final targetFile = File('${directory.path}${Platform.pathSeparator}$targetName');

    await file.copy(targetFile.path);
    return targetFile.path;
  }
}
