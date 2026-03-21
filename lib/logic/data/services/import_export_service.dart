import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/recipe_import_item.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'package:reciplan3/util/storage_service.dart';

class ExportResult {
  final String filePath;
  final bool copiedToDownloads;

  const ExportResult({
    required this.filePath,
    required this.copiedToDownloads,
  });
}

class ImportExportService {
  final StorageService _storageService;

  ImportExportService(this._storageService);

  Future<ExportResult> exportRecipes({
    required List<Recipe> recipes,
    required String fileNamePrefix,
  }) async {
    final jsonString = jsonEncode(recipes);
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_sanitize(fileNamePrefix)}_${_timestamp()}.json';
    final filePath = '${directory.path}${Platform.pathSeparator}$fileName';
    final file = File(filePath);
    await file.writeAsString(jsonString);
    final copiedToDownloads = await _storageService.copyToDownloads(filePath, fileName);

    return ExportResult(
      filePath: filePath,
      copiedToDownloads: copiedToDownloads,
    );
  }

  Future<List<RecipeImportItem>?> pickRecipesForImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    final contents = await file.readAsString();
    final jsonList = jsonDecode(contents) as List<dynamic>;

    return jsonList.map((item) {
      final map = item as Map<String, dynamic>;
      return RecipeImportItem(
        name: map['name'] as String? ?? '',
        mins: map['mins'] as int? ?? 0,
        numIngredients: map['numIngredients'] as int? ?? 0,
        direction: map['direction'] as String? ?? '',
        ingredients: map['ingredients'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        collection: map['collection'] as bool? ?? false,
        favorite: map['favorite'] as bool? ?? false,
        mealType: mealTypeFromDbValue(map['mealType'] as int? ?? MealType.missing.dbValue),
        userCreated: map['userCreated'] as bool? ?? true,
        videoLink: map['videoLink'] as String? ?? '',
      );
    }).toList();
  }

  String _sanitize(String input) {
    final trimmed = input.trim();
    return trimmed.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  String _timestamp() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '$year-$month-${day}_$hour-$minute-$second';
  }
}
