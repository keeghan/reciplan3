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
  Stream<List<Recipe>> getFavoriteRecipes() {
    return _recipeDao.getFavoriteRecipes();
  }

  // Get  collection recipes
  Stream<List<Recipe>> getCollectionRecipes() {
    return _recipeDao.getAllCollectionsRecipes();
  }

  // Get breakfast collection recipes
  Stream<List<Recipe>> getBreakfastCollection() {
    return _recipeDao.getBreakfastCollectionRecipes();
  }

  // Get lunch collection recipes
  Stream<List<Recipe>> getLunchCollection() {
    return _recipeDao.getLunchCollectionRecipes();
  }

  // Get dinner collection recipes
  Stream<List<Recipe>> getDinnerCollection() {
    return _recipeDao.getDinnerCollectionRecipes();
  }

  // Get dinner collection recipes
  // Future<Stream<List<Recipe>>> getSnackCollectionRecipes() async {
  //   return _recipeDao.getSnackRecipes();
  // }

  // Get breakfast collection recipes
  Stream<List<Recipe>> getBreakfasks() {
    return _recipeDao.getBreakfastRecipes();
  }

  // Get lunch collection recipes
  Stream<List<Recipe>> getLunches() {
    return _recipeDao.getLunchRecipes();
  }

  // Get dinner collection recipes
  Stream<List<Recipe>> getDinners() {
    return _recipeDao.getDinnerRecipes();
  }

  // Get dinner collection recipes
  Stream<List<Recipe>> getSnacks() {
    return _recipeDao.getSnackRecipes();
  }

  // Get recipes for active days
  Future<List<Recipe>> getActiveDayRecipes(List<int> dayIds) async {
    return _recipeDao.getActiveDayRecipes(dayIds);
  }

  Stream<List<Recipe>> getThreeRecipesInOrder(
      int breakfastId, int lunchId, int dinnerId) {
    return _recipeDao.getThreeRecipesInOrder(breakfastId, lunchId, dinnerId);
  }
}
