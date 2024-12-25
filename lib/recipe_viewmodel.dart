import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/entities/recipe.dart';

enum RecipeType { breakfast, lunch, dinner, snack, favorite }

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final Map<RecipeType, StreamSubscription?> _subscriptions = {};

  List<Recipe> _recipes = [];
  List<Recipe> _favoriteRecipes = [];
  List<Recipe> _recipeForDay = [];
  bool _isLoading = false;
  String? _error;

  RecipeViewModel(this._recipeRepository);

  // Getters
  List<Recipe> get recipes => _recipes;
  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  List<Recipe> get recipeForDay => _recipeForDay;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _cancelAllSubscriptions();
    super.dispose();
  }

  void _cancelAllSubscriptions() {
    for (var sub in _subscriptions.values) {
      sub?.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> loadRecipes(RecipeType type) async {
    print("${type.toString()} called");

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscriptions[type]?.cancel();

      final Stream<List<Recipe>> stream;
      switch (type) {
        case RecipeType.breakfast:
          stream = await _recipeRepository.getBreakfasks();
        case RecipeType.lunch:
          stream = await _recipeRepository.getLunches();
        case RecipeType.dinner:
          stream = await _recipeRepository.getDinners();
        case RecipeType.snack:
          stream = await _recipeRepository.getSnacks();
        case RecipeType.favorite:
          stream = await _recipeRepository.getFavoriteRecipes();
      }

      _subscriptions[type] = stream.listen(
        (recipes) {
          type == RecipeType.favorite
              ? _favoriteRecipes = recipes
              : _recipes = recipes;
          _isLoading = false;
          notifyListeners();
        },
        onError: handleError,
      );
    } catch (e) {
      handleError(e);
    }
  }

  // Maintain existing helper methods
  void handleError(dynamic e) {
    _isLoading = false;
    _error = 'Failed to load recipes: $e';
    notifyListeners();
  }

  Future<void> loadRecipeForDay(
      int breakfastId, int lunchId, int dinnerId) async {
    try {
      _isLoading = true;
      notifyListeners();
      final stream = await _recipeRepository.getThreeRecipesInOrder(
          breakfastId, lunchId, dinnerId);
      stream.listen(
        (recipes) {
          _recipeForDay = recipes;
          notifyListeners();
        },
        onError: (e) {
          handleError(e);
        },
      );
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> createRecipe(Recipe recipe) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _recipeRepository.createRecipe(recipe);
    } catch (e) {
      _error = 'Failed to create recipe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update recipe
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _recipeRepository.updateRecipe(recipe);
    } catch (e) {
      _error = 'Failed to update recipe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete recipe
  Future<void> deleteRecipe(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _recipeRepository.deleteRecipeById(id);
    } catch (e) {
      _error = 'Failed to delete recipe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
