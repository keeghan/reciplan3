import '../daos/recipe_dao.dart';
import '../entities/recipe.dart';

class RecipeRepository {
  final RecipeDao _recipeDao;

  RecipeRepository(this._recipeDao);

  // Get a single recipe
  Future<Recipe?> getRecipe(int recipeId) async {
    return await _recipeDao.getRecipe(recipeId);
  }

  // Get all recipes
  Future<List<Recipe>> getAllRecipes() async {
    return await _recipeDao.getAllRecipes();
  }

  // Create new recipe
  Future<void> createRecipe(Recipe recipe) async {
    await _recipeDao.insertRecipe(recipe);
  }

  // Update existing recipe
  Future<void> updateRecipe(Recipe recipe) async {
    await _recipeDao.updateRecipe(recipe);
  }

  // Delete recipe
  Future<void> deleteRecipeById(int id) async {
    await _recipeDao.deleteRecipeById(id);
  }

  // Get favorite recipes
  Future<Stream<List<Recipe>>> getFavoriteRecipes() async {
    return _recipeDao.getFavoriteRecipes();
  }

  // Get  collection recipes
  Future<Stream<List<Recipe>>> getCollectionRecipes() async {
    return _recipeDao.getAllCollectionsRecipes();
  }

  // Get breakfast collection recipes
  Future<Stream<List<Recipe>>> getBreakfastCollectionRecipes() async {
    return _recipeDao.getBreakfastCollectionRecipes();
  }

  // Get lunch collection recipes
  Future<Stream<List<Recipe>>> getLunchCollectionRecipes() async {
    return _recipeDao.getLunchCollectionRecipes();
  }

  // Get dinner collection recipes
  Future<Stream<List<Recipe>>> getDinnerCollectionRecipes() async {
    return _recipeDao.getDinnerCollectionRecipes();
  }

  // Get dinner collection recipes
  // Future<Stream<List<Recipe>>> getSnackCollectionRecipes() async {
  //   return _recipeDao.getSnackRecipes();
  // }

  // Get breakfast collection recipes
  Future<Stream<List<Recipe>>> getBreakfasks() async {
    return _recipeDao.getBreakfastRecipes();
  }

  // Get lunch collection recipes
  Future<Stream<List<Recipe>>> getLunches() async {
    return _recipeDao.getLunchRecipes();
  }

  // Get dinner collection recipes
  Future<Stream<List<Recipe>>> getDinners() async {
    return _recipeDao.getDinnerRecipes();
  }

  // Get dinner collection recipes
  Future<Stream<List<Recipe>>> getSnacks() async {
    return _recipeDao.getSnackRecipes();
  }

  // Get recipes for active days
  Future<List<Recipe>> getActiveDayRecipes(List<int> dayIds) async {
    return _recipeDao.getActiveDayRecipes(dayIds);
  }

  Future<Stream<List<Recipe>>> getThreeRecipesInOrder(
      int breakfastId, int lunchId, int dinnerId) async {
    return _recipeDao.getThreeRecipesInOrder(breakfastId, lunchId, dinnerId);
  }
}
