import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/recipes/favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final RecipeRepository _recipeRepository;
  StreamSubscription<List<Recipe>>? _subscription;

  FavoritesCubit(this._recipeRepository) : super(const FavoritesState());

  void watchFavorites() {
    emit(state.copyWith(isLoading: true, clearError: true, clearAction: true));
    _subscription?.cancel();
    _subscription = _recipeRepository.watchFavoriteRecipes().listen(
      (recipes) {
        emit(state.copyWith(isLoading: false, recipes: recipes, clearError: true));
      },
      onError: (Object error) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Error: $error'));
      },
    );
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    try {
      final updatedRecipe = recipe.copyWith(favorite: !recipe.favorite);
      await _recipeRepository.updateRecipe(updatedRecipe);
      emit(
        state.copyWith(
          actionMessage: updatedRecipe.favorite ? 'added to favorite' : 'removed from favorite',
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: 'Error: $error'));
    }
  }

  void clearAction() {
    emit(state.copyWith(clearAction: true));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
