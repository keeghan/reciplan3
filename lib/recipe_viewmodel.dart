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
  List<Recipe> _userCreatedRecipes = [];

  bool _isLoading = false;
  String? _error;

  RecipeViewModel(this._recipeRepository);

  // Getters
  List<Recipe> get recipes => _recipes;

  List<Recipe> get recipeForDay => _recipeForDay;

  List<Recipe> get collections => _collections;

  List<Recipe> get favorites => _favorites;

  List<Recipe> get userCreatedRecipes => _userCreatedRecipes;

  bool get isLoading => _isLoading;

  String? get error => _error;

  //Loads a list of recipes for various screens
  Future<void> loadMealTypeRecipes(RecipeType type) async {
    try {
      setLoading();

      _subscriptions[type]?.cancel();

      final Stream<List<Recipe>> stream;
      switch (type) {
        case RecipeType.breakfast:
          stream = _recipeRepository.getBreakfasks();
        case RecipeType.lunch:
          stream = _recipeRepository.getLunches();
        case RecipeType.dinner:
          stream = _recipeRepository.getDinners();
        case RecipeType.snack:
          stream = _recipeRepository.getSnacks();
        case RecipeType.breakfastCollection:
          stream = _recipeRepository.getBreakfastCollection();
        case RecipeType.lunchCollection:
          stream = _recipeRepository.getLunchCollection();
        case RecipeType.dinnerCollection:
          stream = _recipeRepository.getDinnerCollection();
      }

      _subscriptions[type] = stream.listen(
        (recipes) {
          _recipes = recipes;
          onSuccess();
        },
        onError: onFailure,
      );
    } catch (e) {
      onFailure(e);
    }
  }

  Future<void> loadRecipeForDay(int breakfastId, int lunchId, int dinnerId) async {
    try {
      setLoading();
      final stream = _recipeRepository.getThreeRecipesInOrder(breakfastId, lunchId, dinnerId);
      stream.listen(
        (recipes) {
          _recipeForDay = recipes;
          onSuccess();
        },
        onError: (e) {
          onFailure(e);
        },
      );
    } catch (e) {
      onFailure(e);
    }
  }

  Future<void> loadCollectionRecipes() async {
    try {
      setLoading();
      final stream = _recipeRepository.getCollectionRecipes();
      stream.listen(
        (collections) {
          _collections = collections;
          onSuccess();
        },
        onError: (e) {
          onFailure(e);
        },
      );
    } catch (e) {
      onFailure(e);
    }
  }

  Future<void> loadFavoriteRecipes() async {
    try {
      setLoading();
      final stream = _recipeRepository.getFavoriteRecipes();
      stream.listen(
        (favorites) {
          _favorites = favorites;
          onSuccess();
        },
        onError: (e) {
          onFailure(e);
        },
      );
    } catch (e) {
      onFailure(e);
    }
  }

  Future<List<Recipe>?> getUserCreatedRecipes() async {
    try {
      return await _recipeRepository.getUserCreatedRecipes();
    } catch (e) {
      onFailure(e);
      return null;
    }
  }

  Future<void> createRecipe(Recipe recipe) async {
    try {
      setLoading();
      await _recipeRepository.createRecipe(recipe);
      onSuccess();
    } catch (e) {
      onFailure(e);
    }
  }

  Future<void> insertRecipes(List<Recipe> recipes) async {
    try {
      setLoading();
      await _recipeRepository.insertRecipes(recipes);
      onSuccess();
    } catch (e) {
      onFailure(e);
      rethrow;
    }
  }

  // Update recipe
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      setLoading();
      await _recipeRepository.updateRecipe(recipe);
      onSuccess();
    } catch (e) {
      onFailure(e);
    }
  }

  // Delete recipe
  Future<void> deleteRecipe(int id) async {
    try {
      setLoading();
      await _recipeRepository.deleteRecipeById(id);
      onSuccess();
    } catch (e) {
      onFailure(e);
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
    notifyListeners();
  }

  //Error Handle main
  void onFailure(dynamic e) {
    _isLoading = false;
    _error = 'Error: $e';
    print(e);
    notifyListeners();
  }

  void onSuccess() {
    _error = null;
    _isLoading = false;
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
