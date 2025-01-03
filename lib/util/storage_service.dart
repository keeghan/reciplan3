import 'dart:io';
import 'package:downloadsfolder/downloadsfolder.dart';

class StorageService {
  Future<String> getPublicStorageDirectory() async {
    try {
      Directory downloadDirectory = await getDownloadDirectory();
      return downloadDirectory.path;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> copyToDownloads(String filePath, String fileName) async {
    bool? success = await copyFileIntoDownloadFolder(filePath, fileName,
        desiredExtension: 'json');
    return success ?? false;
  }
}
