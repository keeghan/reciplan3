import 'dart:async';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/recipe_import_item.dart';
import 'package:reciplan3/logic/data/daos/day_dao.dart';
import 'package:reciplan3/logic/data/daos/recipe_dao.dart';
import 'package:reciplan3/logic/data/entities/day.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'package:reciplan3/logic/data/services/import_export_service.dart';
import 'package:reciplan3/logic/data/services/local_image_storage_service.dart';
import 'package:reciplan3/util/storage_service.dart';

Recipe buildRecipe({
  int? id,
  String name = 'Recipe',
  MealType mealType = MealType.breakfast,
  bool collection = true,
  bool favorite = false,
  bool userCreated = true,
  String imageUrl = '/tmp/image.jpg',
}) {
  return Recipe(
    id: id,
    name: name,
    mins: 20,
    numIngredients: 5,
    direction: 'Cook it',
    ingredients: 'A\nB\nC',
    imageUrl: imageUrl,
    collection: collection,
    favorite: favorite,
    mealType: mealType.dbValue,
    userCreated: userCreated,
    videoLink: 'https://example.com',
  );
}

class FakeDayDao extends DayDao {
  FakeDayDao() {
    for (var dayId = 1; dayId <= 7; dayId++) {
      _controllers[dayId] = StreamController<List<Recipe>>.broadcast();
      _dayControllers[dayId] = StreamController<Day?>.broadcast();
    }
  }

  final Map<int, StreamController<List<Recipe>>> _controllers = {};
  final Map<int, StreamController<Day?>> _dayControllers = {};
  final Map<int, List<Recipe>> _latestRecipes = {};
  final Map<int, Day?> _latestDays = {};

  int? updatedBreakfastDayId;
  int? updatedBreakfastRecipeId;
  int? updatedLunchDayId;
  int? updatedLunchRecipeId;
  int? updatedDinnerDayId;
  int? updatedDinnerRecipeId;
  bool clearPlansCalled = false;

  void emitDayRecipes(int dayId, List<Recipe> recipes) {
    _latestRecipes[dayId] = recipes;
    _controllers[dayId]!.add(recipes);
  }

  void emitDay(
    int dayId, {
    int breakfast = 0,
    int lunch = 1,
    int dinner = 2,
  }) {
    final day = Day(
      id: dayId,
      name: 'Day $dayId',
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
    );
    _latestDays[dayId] = day;
    _dayControllers[dayId]!.add(day);
  }

  void emitDayError(int dayId, Object error) {
    _controllers[dayId]!.addError(error);
  }

  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
    for (final controller in _dayControllers.values) {
      await controller.close();
    }
  }

  @override
  Future<void> clearCollection() async {}

  @override
  Future<void> clearFavorite() async {}

  @override
  Future<void> clearPlans() async {
    clearPlansCalled = true;
  }

  @override
  Future<List<Day>> getAllDays() async => const [];

  @override
  Future<Day?> getDay(int dayId) async => null;

  @override
  Stream<Day?> watchDay(int dayId) async* {
    if (_latestDays.containsKey(dayId)) {
      yield _latestDays[dayId];
    }
    yield* _dayControllers[dayId]!.stream;
  }

  @override
  Stream<List<Recipe>> getRecipesForDay(int dayId) async* {
    if (_latestRecipes.containsKey(dayId)) {
      yield _latestRecipes[dayId]!;
    }
    yield* _controllers[dayId]!.stream;
  }

  @override
  Future<void> insertDay(Day day) async {}

  @override
  Future<void> insertDays(List<Day> days) async {}

  @override
  Future<void> updateBreakfast(int dayId, int recipeId) async {
    updatedBreakfastDayId = dayId;
    updatedBreakfastRecipeId = recipeId;
  }

  @override
  Future<void> updateDay(Day day) async {}

  @override
  Future<void> updateDinner(int dayId, int recipeId) async {
    updatedDinnerDayId = dayId;
    updatedDinnerRecipeId = recipeId;
  }

  @override
  Future<void> updateLunch(int dayId, int recipeId) async {
    updatedLunchDayId = dayId;
    updatedLunchRecipeId = recipeId;
  }
}

class FakeRecipeDao extends RecipeDao {
  Stream<List<Recipe>> breakfastRecipes = const Stream.empty();
  Stream<List<Recipe>> lunchRecipes = const Stream.empty();
  Stream<List<Recipe>> dinnerRecipes = const Stream.empty();
  Stream<List<Recipe>> snackRecipes = const Stream.empty();
  Stream<List<Recipe>> collectionRecipes = const Stream.empty();
  Stream<List<Recipe>> favoriteRecipes = const Stream.empty();
  Stream<List<Recipe>> breakfastCollectionRecipes = const Stream.empty();
  Stream<List<Recipe>> lunchCollectionRecipes = const Stream.empty();
  Stream<List<Recipe>> dinnerCollectionRecipes = const Stream.empty();
  Stream<List<Recipe>> snackCollectionRecipes = const Stream.empty();

  List<Recipe> userCreatedRecipes = const [];
  Recipe? lastInsertedRecipe;
  Recipe? lastUpdatedRecipe;
  List<Recipe>? lastImportedRecipes;
  int? lastDeletedRecipeId;

  @override
  Future<void> clearCollection() async {}

  @override
  Future<void> clearFavorite() async {}

  @override
  Future<void> clearPlans() async {}

  @override
  Future<void> clearRecipeFromBreakfast(int recipeId) async {}

  @override
  Future<void> clearRecipeFromDinner(int recipeId) async {}

  @override
  Future<void> clearRecipeFromLunch(int recipeId) async {}

  @override
  Future<void> deleteRecipe(Recipe recipe) async {}

  @override
  Future<void> deleteRecipeById(int id) async {
    lastDeletedRecipeId = id;
  }

  @override
  Future<List<Recipe>> getActiveDayRecipes(List<int> dayIDs) async => const [];

  @override
  Stream<List<Recipe>> getAllCollectionsRecipes() => collectionRecipes;

  @override
  Future<List<Recipe>> getAllRecipes() async => const [];

  @override
  Stream<List<Recipe>> getBreakfastCollectionRecipes() => breakfastCollectionRecipes;

  @override
  Stream<List<Recipe>> getBreakfastRecipes() => breakfastRecipes;

  @override
  Stream<List<Recipe>> getDinnerCollectionRecipes() => dinnerCollectionRecipes;

  @override
  Stream<List<Recipe>> getDinnerRecipes() => dinnerRecipes;

  @override
  Stream<List<Recipe>> getFavoriteRecipes() => favoriteRecipes;

  @override
  Stream<List<Recipe>> getLunchCollectionRecipes() => lunchCollectionRecipes;

  @override
  Stream<List<Recipe>> getLunchRecipes() => lunchRecipes;

  @override
  Future<Recipe?> getRecipe(int recipeId) async => null;

  @override
  Stream<List<Recipe>> getSnackCollectionRecipes() => snackCollectionRecipes;

  @override
  Stream<List<Recipe>> getSnackRecipes() => snackRecipes;

  @override
  Stream<List<Recipe>> getThreeRecipesInOrder(int firstId, int secondId, int thirdId) {
    return const Stream.empty();
  }

  @override
  Future<List<Recipe>> getUserCreatedRecipes() async => userCreatedRecipes;

  @override
  Future<void> insertRecipe(Recipe recipe) async {
    lastInsertedRecipe = recipe;
  }

  @override
  Future<void> insertRecipes(List<Recipe> recipes) async {
    lastImportedRecipes = recipes;
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    lastUpdatedRecipe = recipe;
  }
}

class FakeLocalImageStorageService extends LocalImageStorageService {
  String storedPath = '/stored/image.jpg';
  Object? error;
  String? lastSourcePath;

  @override
  Future<String> storeImage(String sourcePath) async {
    lastSourcePath = sourcePath;
    if (error != null) {
      throw error!;
    }
    return storedPath;
  }
}

class FakeImportExportService extends ImportExportService {
  FakeImportExportService() : super(StorageService());

  ExportResult exportResult = const ExportResult(
    filePath: '/tmp/export.json',
    copiedToDownloads: true,
  );
  Object? exportError;
  Object? importError;
  List<RecipeImportItem>? importItems;
  List<Recipe>? exportedRecipes;
  String? exportedFileNamePrefix;

  @override
  Future<ExportResult> exportRecipes({
    required List<Recipe> recipes,
    required String fileNamePrefix,
  }) async {
    exportedRecipes = recipes;
    exportedFileNamePrefix = fileNamePrefix;
    if (exportError != null) {
      throw exportError!;
    }
    return exportResult;
  }

  @override
  Future<List<RecipeImportItem>?> pickRecipesForImport() async {
    if (importError != null) {
      throw importError!;
    }
    return importItems;
  }
}
