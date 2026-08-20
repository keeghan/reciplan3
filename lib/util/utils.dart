import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';

class DayIds {
  static const int sunday = 1;
  static const int monday = 2;
  static const int tuesday = 3;
  static const int wednesday = 4;
  static const int thursday = 5;
  static const int friday = 6;
  static const int saturday = 7;
}

class MyUtils {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

//match day with id
  static String getDayName(int dayId) {
    switch (dayId) {
      case DayIds.sunday:
        return 'Sunday';
      case DayIds.monday:
        return 'Monday';
      case DayIds.tuesday:
        return 'Tuesday';
      case DayIds.wednesday:
        return 'Wednesday';
      case DayIds.thursday:
        return 'Thursday';
      case DayIds.friday:
        return 'Friday';
      case DayIds.saturday:
        return 'Saturday';
      default:
        throw Exception("Invalid Day Id");
    }
  }

  static Future<Map<String, dynamic>> storeFileInAppDocumentsDirectory(
      File file) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filename = file.path.split('/').last;
      final extension = filename.split('.').last;

      final newFilename = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final newFile = File('${directory.path}/$newFilename');

      await file.copy(newFile.path);

      return {'success': true, 'filePath': newFile.path};
    } catch (error) {
      return {'success': false, 'errorMessage': 'Error storing file: $error'};
    }
  }

  static void showDeleteConfirmationDialog(BuildContext context, String title,
      String msg, String positive, Function func) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                func();
                Navigator.of(context).pop();
              },
              child: Text(positive),
            ),
          ],
        );
      },
    );
  }

  static Future<List<Recipe>> convertToRecipes(
      List<dynamic> recipesJson) async {
    return recipesJson.map((recipeMap) {
      return Recipe(
          id: recipeMap['id'] as int?,
          name: recipeMap['name'],
          mins: recipeMap['mins'],
          numIngredients: recipeMap['numIngredients'],
          direction: recipeMap['direction'],
          ingredients: recipeMap['ingredients'],
          imageUrl: recipeMap['imageUrl'],
          collection: recipeMap['collection'],
          favorite: recipeMap['favorite'],
          mealType: mealTypeFromDbValue(recipeMap['mealType']).dbValue,
          userCreated: recipeMap['userCreated'] ?? true,
          videoLink: recipeMap['videoLink']);
    }).toList();
  }
}
