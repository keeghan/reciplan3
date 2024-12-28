import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/entities/recipe.dart';

enum RecipeType {
  breakfast,
  lunch,
  dinner,
  snack,
  //mealType:Collection used my ManageDayScreen
  breakfastCollection,
  lunchCollection,
  dinnerCollection,
}

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final Map<RecipeType, StreamSubscription?> _subscriptions = {};

  List<Recipe> _recipes = [];
  List<Recipe> _recipeForDay = [];
  //handle collections and favorites separately
  List<Recipe> _collections = [];
  List<Recipe> _favorites = [];

  bool _isLoading = false;
  String? _error;

  RecipeViewModel(this._recipeRepository);

  // Getters
  List<Recipe> get recipes => _recipes;
  List<Recipe> get recipeForDay => _recipeForDay;
  List<Recipe> get collections => _collections;
  List<Recipe> get favorites => _favorites;

  bool get isLoading => _isLoading;
  String? get error => _error;

  //Loads a list of recipes for various screens
  Future<void> loadMealTypeRecipes(RecipeType type) async {
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
        case RecipeType.breakfastCollection:
          stream = await _recipeRepository.getBreakfastCollection();
        case RecipeType.lunchCollection:
          stream = await _recipeRepository.getLunchCollection();
        case RecipeType.dinnerCollection:
          stream = await _recipeRepository.getDinnerCollection();
      }

      _subscriptions[type] = stream.listen(
        (recipes) {
          _recipes = recipes;
          _isLoading = false;
          notifyListeners();
        },
        onError: handleError,
      );
    } catch (e) {
      handleError(e);
    }
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

  Future<void> loadCollectionRecipes() async {
    try {
      _isLoading = true;
      notifyListeners();
      final stream = await _recipeRepository.getCollectionRecipes();
      stream.listen(
        (collections) {
          _collections = collections;
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

  Future<void> loadFavoriteRecipes() async {
    try {
      _isLoading = true;
      notifyListeners();
      final stream = await _recipeRepository.getFavoriteRecipes();
      stream.listen(
        (favorites) {
          _favorites = favorites;
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
      setLoading();
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
      setLoading();
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
      setLoading();
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

  void setLoading() {
    _isLoading = true;
    _error = null;
  }

  // Maintain existing helper methods
  void handleError(dynamic e) {
    _isLoading = false;
    _error = 'Failed to load recipes: $e';
    notifyListeners();
  }

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
}
