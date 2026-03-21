import 'package:flutter_test/flutter_test.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/recipe_import_item.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/settings/import_export_cubit.dart';
import 'package:reciplan3/logic/settings/import_export_state.dart';

import '../../support/test_fakes.dart';

void main() {
  group('ImportExportCubit', () {
    late FakeRecipeDao recipeDao;
    late FakeImportExportService importExportService;
    late ImportExportCubit cubit;

    setUp(() {
      recipeDao = FakeRecipeDao();
      importExportService = FakeImportExportService();
      cubit = ImportExportCubit(
        RecipeRepository(recipeDao),
        importExportService,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('exportRecipes emits an error when there are no local recipes', () async {
      final emittedStates = <ImportExportState>[];
      final subscription = cubit.stream.listen(emittedStates.add);
      recipeDao.userCreatedRecipes = const [];

      await cubit.exportRecipes('recipes');
      await Future<void>.delayed(Duration.zero);

      expect(emittedStates, isNotEmpty);
      expect(emittedStates.first.isBusy, isTrue);
      expect(emittedStates.last.errorMessage, 'No local recipes to export');
      expect(importExportService.exportedRecipes, isNull);

      await subscription.cancel();
    });

    test('exportRecipes emits a success message when export completes', () async {
      final emittedStates = <ImportExportState>[];
      final subscription = cubit.stream.listen(emittedStates.add);
      recipeDao.userCreatedRecipes = [
        buildRecipe(id: 7, name: 'Banku', mealType: MealType.lunch),
      ];

      await cubit.exportRecipes('my_recipes');
      await Future<void>.delayed(Duration.zero);

      expect(importExportService.exportedRecipes, hasLength(1));
      expect(importExportService.exportedFileNamePrefix, 'my_recipes');
      expect(emittedStates, isNotEmpty);
      expect(emittedStates.last.successMessage, 'Exported to Downloads folder');

      await subscription.cancel();
    });

    test('importRecipes inserts imported recipes and emits success', () async {
      final emittedStates = <ImportExportState>[];
      final subscription = cubit.stream.listen(emittedStates.add);
      importExportService.importItems = const [
        RecipeImportItem(
          name: 'Kenkey',
          mins: 40,
          numIngredients: 3,
          direction: 'Boil',
          ingredients: 'Corn dough',
          imageUrl: '/tmp/kenkey.jpg',
          collection: true,
          favorite: false,
          mealType: MealType.lunch,
          userCreated: true,
          videoLink: '',
        ),
      ];

      await cubit.importRecipes();
      await Future<void>.delayed(Duration.zero);

      expect(recipeDao.lastImportedRecipes, hasLength(1));
      expect(recipeDao.lastImportedRecipes!.single.name, 'Kenkey');
      expect(emittedStates, isNotEmpty);
      expect(emittedStates.last.successMessage, '1 recipes imported');

      await subscription.cancel();
    });
  });
}
