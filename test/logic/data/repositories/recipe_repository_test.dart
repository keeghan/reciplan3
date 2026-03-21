import 'package:flutter_test/flutter_test.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/recipe_draft.dart';
import 'package:reciplan3/logic/core/models/recipe_import_item.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';

import '../../../support/test_fakes.dart';

void main() {
  group('RecipeRepository', () {
    late FakeRecipeDao recipeDao;
    late RecipeRepository repository;

    setUp(() {
      recipeDao = FakeRecipeDao();
      repository = RecipeRepository(recipeDao);
    });

    test('watchRecipesByMealType returns the matching dao stream', () async {
      recipeDao.lunchRecipes = Stream.value([
        buildRecipe(id: 1, name: 'Light Soup', mealType: MealType.lunch),
      ]);

      final recipes = await repository.watchRecipesByMealType(MealType.lunch).first;

      expect(recipes, hasLength(1));
      expect(recipes.single.name, 'Light Soup');
      expect(recipes.single.mealTypeEnum, MealType.lunch);
    });

    test('createRecipe maps draft fields into a user-created entity', () async {
      const draft = RecipeDraft(
        name: 'Jollof',
        mins: 45,
        numIngredients: 9,
        direction: 'Cook slowly',
        ingredients: 'Rice\nTomato',
        imagePath: '/tmp/jollof.jpg',
        collection: true,
        favorite: true,
        mealType: MealType.dinner,
        videoLink: 'https://example.com/jollof',
      );

      await repository.createRecipe(draft);

      final inserted = recipeDao.lastInsertedRecipe;
      expect(inserted, isNotNull);
      expect(inserted!.name, 'Jollof');
      expect(inserted.imageUrl, '/tmp/jollof.jpg');
      expect(inserted.mealType, MealType.dinner.dbValue);
      expect(inserted.userCreated, isTrue);
      expect(inserted.favorite, isTrue);
    });

    test('importRecipes maps import items into recipe entities', () async {
      const items = [
        RecipeImportItem(
          name: 'Kelewele',
          mins: 15,
          numIngredients: 4,
          direction: 'Fry',
          ingredients: 'Plantain',
          imageUrl: '/tmp/kelewele.jpg',
          collection: true,
          favorite: false,
          mealType: MealType.snack,
          userCreated: true,
          videoLink: '',
        ),
      ];

      await repository.importRecipes(items);

      final imported = recipeDao.lastImportedRecipes;
      expect(imported, isNotNull);
      expect(imported, hasLength(1));
      expect(imported!.single.name, 'Kelewele');
      expect(imported.single.mealTypeEnum, MealType.snack);
      expect(imported.single.userCreated, isTrue);
    });
  });
}
