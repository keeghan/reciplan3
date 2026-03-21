import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/recipe_draft.dart';
import 'package:reciplan3/logic/core/models/recipe_import_item.dart';
import 'package:reciplan3/logic/data/daos/recipe_dao.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';

class RecipeRepository {
  final RecipeDao _recipeDao;

  RecipeRepository(this._recipeDao);

  Stream<List<Recipe>> watchRecipesByMealType(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return _recipeDao.getBreakfastRecipes();
      case MealType.lunch:
        return _recipeDao.getLunchRecipes();
      case MealType.dinner:
        return _recipeDao.getDinnerRecipes();
      case MealType.snack:
        return _recipeDao.getSnackRecipes();
      case MealType.missing:
        return const Stream<List<Recipe>>.empty();
    }
  }

  Stream<List<Recipe>> watchCollectionRecipes() {
    return _recipeDao.getAllCollectionsRecipes();
  }

  Stream<List<Recipe>> watchCollectionRecipesByMealType(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return _recipeDao.getBreakfastCollectionRecipes();
      case MealType.lunch:
        return _recipeDao.getLunchCollectionRecipes();
      case MealType.dinner:
        return _recipeDao.getDinnerCollectionRecipes();
      case MealType.snack:
        return _recipeDao.getSnackCollectionRecipes();
      case MealType.missing:
        return const Stream<List<Recipe>>.empty();
    }
  }

  Stream<List<Recipe>> watchFavoriteRecipes() {
    return _recipeDao.getFavoriteRecipes();
  }

  Future<List<Recipe>> getUserCreatedRecipes() {
    return _recipeDao.getUserCreatedRecipes();
  }

  Future<void> createRecipe(RecipeDraft draft) {
    return _recipeDao.insertRecipe(
      Recipe(
        name: draft.name,
        mins: draft.mins,
        numIngredients: draft.numIngredients,
        direction: draft.direction,
        ingredients: draft.ingredients,
        imageUrl: draft.imagePath,
        collection: draft.collection,
        favorite: draft.favorite,
        mealType: draft.mealType.dbValue,
        userCreated: true,
        videoLink: draft.videoLink,
      ),
    );
  }

  Future<void> updateRecipe(Recipe recipe) {
    return _recipeDao.updateRecipe(recipe);
  }

  Future<void> deleteRecipe(int id) {
    return _recipeDao.deleteRecipeById(id);
  }

  Future<void> importRecipes(List<RecipeImportItem> recipes) {
    return _recipeDao.insertRecipes(
      recipes
          .map(
            (item) => Recipe(
              name: item.name,
              mins: item.mins,
              numIngredients: item.numIngredients,
              direction: item.direction,
              ingredients: item.ingredients,
              imageUrl: item.imageUrl,
              collection: item.collection,
              favorite: item.favorite,
              mealType: item.mealType.dbValue,
              userCreated: item.userCreated,
              videoLink: item.videoLink,
            ),
          )
          .toList(),
    );
  }
}
