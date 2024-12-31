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
      });
      onSuccess();
    } catch (e) {
      onError(e);
    }
  }

  //Method to add a recipe to a day
  Future<void> addRecipeToDay(int dayId, int mealType, recipeId) async {
    try {
      await _dayRepository.updateDayMeal(dayId, mealType, recipeId);
      onSuccess();
    } catch (e) {
      onError(e);
    }
  }

  //Clear all Week plans
  Future<void> clearPlans() async {
    try {
      await _dayRepository.clearPlans();
      onSuccess();
    } catch (e) {
      onError(e);
    }
  }

  void onError(dynamic e) {
    _isLoading = false;
    _isSuccess = false;
    _error = 'Error: $e';
    notifyListeners();
  }

  void onSuccess() {
    _error = null;
    _isLoading = false;
    _isSuccess = true;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
