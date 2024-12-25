import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/entities/recipe.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  List<Recipe> _recipes = [];
  List<Recipe> _favoriteRecipes = [];
  List<Recipe> _recipeForDay = [];
  bool _isLoading = false;
  String? _error;

  // Store stream subscriptions
  StreamSubscription? _breakfastSubscription;
  StreamSubscription? _lunchSubscription;
  StreamSubscription? _dinnerSubscription;
  StreamSubscription? _snackSubscription;
  StreamSubscription? _favoriteSubscription;

  RecipeViewModel(this._recipeRepository);

  // Getters
  List<Recipe> get recipes => _recipes;

  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  List<Recipe> get recipeForDay => _recipeForDay;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _cancelSubscriptions() {
    _breakfastSubscription?.cancel();
    _lunchSubscription?.cancel();
    _dinnerSubscription?.cancel();
    _snackSubscription?.cancel();
    _favoriteSubscription?.cancel();
  }

  //breakfast
  Future<void> loadBreakfastRecipes() async {
        print("breakfast called");

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _breakfastSubscription?.cancel();
      final stream = await _recipeRepository.getBreakfastCollectionRecipes();
      _breakfastSubscription = stream.listen(
        (recipes) {
          _recipes = recipes;
          _isLoading = false;
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

//Lunch
  Future<void> loadLunchRecipes() async {
    print("lucnch called");
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _lunchSubscription?.cancel();
      final stream = await _recipeRepository.getLunchCollectionRecipes();
      _lunchSubscription = stream.listen(
        (recipes) {
          _recipes = recipes;
          _isLoading = false;
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

  //Dinenr
  Future<void> loadDinnerRecipes() async {
        print("diner called");

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _dinnerSubscription?.cancel();
      final stream = await _recipeRepository.getDinnerCollectionRecipes();
      _dinnerSubscription = stream.listen(
        (recipes) {
          _recipes = recipes;
          _isLoading = false;
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

//Snack
  Future<void> loadSnackRecipes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _snackSubscription?.cancel();
      final stream =
          await _recipeRepository.getSnackCollectionRecipes(); // Fixed method
      _snackSubscription = stream.listen(
        (recipes) {
          _recipes = recipes;
          _isLoading = false;
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
      _error = null;
      notifyListeners();

      _favoriteSubscription?.cancel();
      final stream = await _recipeRepository.getFavoriteRecipes();
      _favoriteSubscription = stream.listen(
        (recipes) {
          _favoriteRecipes = recipes;
          _isLoading = false;
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

  handleError(dynamic e) {
    _isLoading = false;
    _error = 'Failed to load favorite recipes: $e';
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
