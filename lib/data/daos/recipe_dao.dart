import 'package:floor/floor.dart';
import 'package:reciplan3/util/util.dart';

import '../entities/recipe.dart';

@dao
abstract class RecipeDao {
  //Update Functions

  @insert
  Future<void> insertRecipe(Recipe recipe);

  @update
  Future<void> updateRecipe(Recipe recipe);

  @delete
  Future<void> deleteRecipe(Recipe recipe);

  @Query('DELETE FROM recipe_table WHERE id = :id')
  Future<void> deleteRecipeById(int id);

  @Query('UPDATE day_table SET breakfast = 0 WHERE breakfast = :recipeId')
  Future<void> clearRecipeFromBreakfast(int recipeId);

  @Query('UPDATE day_table SET lunch = 1 WHERE lunch = :recipeId')
  Future<void> clearRecipeFromLunch(int recipeId);

  @Query('UPDATE day_table SET dinner = 2 WHERE dinner = :recipeId')
  Future<void> clearRecipeFromDinner(int recipeId);

  @Query("UPDATE recipe_table SET collection = 0, favorite = 0")
  Future<void> clearCollection();

  @Query("UPDATE recipe_table SET favorite = 0")
  Future<void> clearFavorite();

  @Query("UPDATE day_table SET breakfast = 0, lunch = 1, dinner = 2")
  Future<void> clearPlans();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertRecipes(List<Recipe> recipes);

  @transaction
  Future<void> deleteRecipeWithClear(Recipe recipe) async {
    switch (recipe.mealType) {
      case MealType.breakfast:
        await clearRecipeFromBreakfast(recipe.id);
        break;
      case MealType.lunch:
        await clearRecipeFromLunch(recipe.id);
        break;
      case MealType.dinner:
        await clearRecipeFromDinner(recipe.id);
        break;
      default:
        throw Exception("default recipe being deleted");
    }
    await deleteRecipe(recipe);
  }

  //Retrieval Functions
  @Query('SELECT * FROM recipe_table WHERE id = :recipeId')
  Future<Recipe?> getRecipe(int recipeId);

  @Query('SELECT * FROM recipe_table ORDER BY id DESC')
  Future<List<Recipe>> getAllRecipes();

  @Query('SELECT * FROM recipe_table WHERE favorite = 1 ORDER BY id DESC')
  Stream<List<Recipe>> getFavoriteRecipes();

  @Query("SELECT * FROM recipe_table WHERE mealType = 0 ORDER BY id DESC")
  Stream<List<Recipe>> getBreakfastRecipes();

  @Query("SELECT * FROM recipe_table WHERE mealType = 1 ORDER BY id DESC")
  Stream<List<Recipe>> getLunchRecipes();

  @Query("SELECT * FROM recipe_table WHERE mealType = 2 ORDER BY id DESC")
  Stream<List<Recipe>> getDinnerRecipes();

  @Query("SELECT * FROM recipe_table WHERE mealType = 3 ORDER BY id DESC")
  Stream<List<Recipe>> getSnackRecipes();

  //Collection functions
  @Query('SELECT * FROM recipe_table WHERE collection = 1 ORDER BY id DESC')
  Stream<List<Recipe>> getAllCollectionsRecipes();

  @Query("SELECT * FROM recipe_table WHERE mealType = 0 AND collection = 1")
  Stream<List<Recipe>> getBreakfastCollectionRecipes();

  @Query("SELECT * FROM recipe_table WHERE mealType = 2 AND collection = 1")
  Stream<List<Recipe>> getDinnerCollectionRecipes();

  @Query("SELECT * FROM recipe_table WHERE mealType = 1 AND collection = 1")
  Stream<List<Recipe>> getLunchCollectionRecipes();

  @Query("SELECT * FROM recipe_table WHERE mealType = 3 AND collection = 1")
  Stream<List<Recipe>> getSnackCollectionRecipes();

  @Query("SELECT * FROM recipe_table WHERE id IN (:dayIDs)")
  Future<List<Recipe>> getActiveDayRecipes(List<int> dayIDs);

  @Query('''
    SELECT * FROM recipe_table 
    WHERE id = :firstId OR id = :secondId OR id = :thirdId
    ORDER BY CASE id 
      WHEN :firstId THEN 1 
      WHEN :secondId THEN 2 
      WHEN :thirdId THEN 3 
    END
  ''')
  Stream<List<Recipe>> getThreeRecipesInOrder(
    int firstId,
    int secondId,
    int thirdId,
  );
}
