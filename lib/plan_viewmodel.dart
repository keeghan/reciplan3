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

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get msg => _msg;

  Map<int, List<Recipe>> _weekRecipes = {};
  Map<int, List<Recipe>> get weekRecipes => _weekRecipes;

  StreamSubscription<Map<int, List<Recipe>>>? _weekRecipesSubscription;

  PlanViewModel(this._dayRepository) {
    loadWeekRecipes();
  }

  void loadWeekRecipes() {
    _isLoading = true;
    notifyListeners();
    try {
      _weekRecipesSubscription?.cancel();
      _weekRecipesSubscription = _dayRepository.getWeekRecipes().listen((weekRecipes) {
        _weekRecipes = weekRecipes;
        onSuccess();
      }, onError: (error) {
        onFailure(error);
      });
    } catch (e) {
      onFailure(e);
    }
  }

  //Method to add a recipe to a day
  Future<void> addRecipeToDay(int dayId, int mealType, recipeId) async {
    try {
      await _dayRepository.updateDayMeal(dayId, mealType, recipeId);
      onSuccess();
    } catch (e) {
      onFailure(e);
    }
  }

  //Clear all Week plans
  Future<void> clearPlans() async {
    try {
      await _dayRepository.clearPlans();
      onSuccess();
    } catch (e) {
      onFailure(e);
    }
  }

  void onFailure(dynamic e) {
    _isLoading = false;
    _error = 'Error: $e';
    notifyListeners();
  }

  void onSuccess() {
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _weekRecipesSubscription?.cancel();
    super.dispose();
  }
}
