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

//Stream for plan_page
  Stream<Map<int, List<Recipe>>> get weekRecipesStream {
    return _dayRepository.getWeekRecipes().asBroadcastStream();
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
      //use mealType as recipeId to set recipe as empty (0,1,2)
      await _dayRepository.updateDayMeal(dayId, mealType, mealType);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update recipe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
