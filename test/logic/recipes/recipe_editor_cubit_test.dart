import 'package:flutter_test/flutter_test.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/recipe_draft.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/recipes/recipe_editor_cubit.dart';
import 'package:reciplan3/logic/recipes/recipe_editor_state.dart';

import '../../support/test_fakes.dart';

void main() {
  group('RecipeEditorCubit', () {
    late FakeRecipeDao recipeDao;
    late FakeLocalImageStorageService imageStorageService;
    late RecipeEditorCubit cubit;

    const draft = RecipeDraft(
      name: 'Fufu',
      mins: 60,
      numIngredients: 6,
      direction: 'Pound',
      ingredients: 'Cassava\nPlantain',
      imagePath: '/source/fufu.jpg',
      collection: true,
      favorite: false,
      mealType: MealType.dinner,
      videoLink: 'https://example.com/fufu',
    );

    setUp(() {
      recipeDao = FakeRecipeDao();
      imageStorageService = FakeLocalImageStorageService();
      cubit = RecipeEditorCubit(
        RecipeRepository(recipeDao),
        imageStorageService,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('saveRecipe stores the image first and then inserts the recipe', () async {
      final emittedStates = <RecipeEditorState>[];
      final subscription = cubit.stream.listen(emittedStates.add);

      await cubit.saveRecipe(draft);
      await Future<void>.delayed(Duration.zero);

      expect(imageStorageService.lastSourcePath, '/source/fufu.jpg');
      expect(recipeDao.lastInsertedRecipe, isNotNull);
      expect(recipeDao.lastInsertedRecipe!.imageUrl, imageStorageService.storedPath);
      expect(recipeDao.lastInsertedRecipe!.userCreated, isTrue);
      expect(emittedStates, isNotEmpty);
      expect(emittedStates.first.isSaving, isTrue);
      expect(emittedStates.last.saveSuccess, isTrue);

      await subscription.cancel();
    });

    test('saveRecipe emits an error when image storage fails', () async {
      final emittedStates = <RecipeEditorState>[];
      final subscription = cubit.stream.listen(emittedStates.add);
      imageStorageService.error = Exception('disk full');

      await cubit.saveRecipe(draft);
      await Future<void>.delayed(Duration.zero);

      expect(recipeDao.lastInsertedRecipe, isNull);
      expect(emittedStates, isNotEmpty);
      expect(emittedStates.first.isSaving, isTrue);
      expect(emittedStates.last.isSaving, isFalse);
      expect(emittedStates.last.errorMessage, contains('disk full'));

      await subscription.cancel();
    });
  });
}
