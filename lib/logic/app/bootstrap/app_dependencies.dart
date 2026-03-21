import 'package:shared_preferences/shared_preferences.dart';

import 'package:reciplan3/logic/data/db/database_provider.dart';
import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/data/services/import_export_service.dart';
import 'package:reciplan3/logic/data/services/local_image_storage_service.dart';
import 'package:reciplan3/logic/data/services/preferences_service.dart';
import 'package:reciplan3/util/storage_service.dart';

class AppDependencies {
  final RecipeRepository recipeRepository;
  final MealPlanRepository mealPlanRepository;
  final PreferencesService preferencesService;
  final ImportExportService importExportService;
  final LocalImageStorageService localImageStorageService;

  const AppDependencies({
    required this.recipeRepository,
    required this.mealPlanRepository,
    required this.preferencesService,
    required this.importExportService,
    required this.localImageStorageService,
  });

  static Future<AppDependencies> bootstrap() async {
    final database = await DatabaseProvider.database;
    final sharedPreferences = await SharedPreferences.getInstance();
    final preferencesService = PreferencesService(sharedPreferences);

    return AppDependencies(
      recipeRepository: RecipeRepository(database.recipeDao),
      mealPlanRepository: MealPlanRepository(database.dayDao),
      preferencesService: preferencesService,
      importExportService: ImportExportService(StorageService()),
      localImageStorageService: LocalImageStorageService(),
    );
  }
}
