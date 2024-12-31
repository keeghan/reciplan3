import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reciplan3/data/repositories/day_repository.dart';
import '../../data/entities/recipe.dart';

//Repository for PlanPage and ManagePlanScreen
class PlanViewModel extends ChangeNotifier {
  final DayRepository _dayRepository;

  bool _isLoading = false;
  String? _error;
  String? _msg;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get msg => _msg;
  bool get isSuccess => _isSuccess;

  Map<int, List<Recipe>> _weekRecipes = {};
  Map<int, List<Recipe>> get weekRecipes => _weekRecipes;

  PlanViewModel(this._dayRepository);

  Future<void> loadWeekRecipes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final stream = _dayRepository.getWeekRecipes();
      stream.listen((weekRecipes) {
        _weekRecipes = weekRecipes;
        _isLoading = false;
        notifyListeners();
      });
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      handleError(e);
    }
  }

  //Method to add a recipe to a day
  Future<void> addRecipeToDay(int dayId, int mealType, recipeId) async {
    try {
      await _dayRepository.updateDayMeal(dayId, mealType, recipeId);
      _isSuccess = true;
    } catch (e) {
      _isSuccess = false;
      _error = e.toString();
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