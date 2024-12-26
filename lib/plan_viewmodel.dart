import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reciplan3/data/repositories/day_repository.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/entities/recipe.dart';
import 'data/entities/day.dart';

//Repository for PlanPage and ManagePlanScreen
class PlanViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final DayRepository _dayRepository;

  bool _isLoading = false;
  String? _error;

  PlanViewModel(this._recipeRepository, this._dayRepository);

  Stream<Map<int, List<Recipe>>>? _weekRecipesStream;
  Map<int, List<Recipe>>? _weekRecipes;

  Map<int, List<Recipe>>? get weekRecipes => _weekRecipes;

  // Convert the stream to a broadcast stream to allow multiple listeners
  Stream<Map<int, List<Recipe>>>? get weekRecipesStream {
    return _weekRecipesStream?.asBroadcastStream();
  }

  //load all the streams of recipes for the week
  void loadWeekRecipes() {
    _isLoading = true;
    notifyListeners();
    //Todo: implement error check (beware of stream already listen to error)
    _weekRecipesStream = _dayRepository.getWeekRecipes();
  }

  // Update recipe
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      _isLoading = true;
      _error = null;
      await _recipeRepository.updateRecipe(recipe);
    } catch (e) {
      _error = 'Failed to update recipe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Method to remove a recipe from a day
  Future<void> clearRecipeInDay(int dayId, int mealType) async {
    try {
      _isLoading = true;
      _error = null;
      //use mealType recipeId to set recipe as empty (0,1,2)
      await _dayRepository.updateDayMeal(dayId, mealType, mealType);
    } catch (e) {
      _error = 'Failed to update recipe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Maintain existing helper methods
  void handleError(dynamic e) {
    _isLoading = false;
    _error = 'Failed to load recipes: $e';
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
