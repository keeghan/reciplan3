import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/recipes/recipe_catalog_state.dart';

class RecipeCatalogCubit extends Cubit<RecipeCatalogState> {
  final RecipeRepository _recipeRepository;
  StreamSubscription<List<Recipe>>? _subscription;

  RecipeCatalogCubit(this._recipeRepository) : super(const RecipeCatalogState());

  void watchMealType(MealType mealType) {
    emit(state.copyWith(isLoading: true, clearError: true, clearAction: true));
    _subscription?.cancel();
    _subscription = _recipeRepository.watchRecipesByMealType(mealType).listen(
      (recipes) {
        emit(
          state.copyWith(
            isLoading: false,
            recipes: recipes,
            clearError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Error: $error',
          ),
        );
      },
    );
  }

  Future<void> toggleCollection(Recipe recipe, bool inCollection) async {
    await _runRecipeMutation(
      recipe.copyWith(collection: inCollection),
      inCollection ? '${recipe.name} added to collection' : '${recipe.name} removed from collection',
    );
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    try {
      await _recipeRepository.deleteRecipe(recipe.id!);
      emit(state.copyWith(actionMessage: '${recipe.name} deleted'));
    } catch (error) {
      emit(state.copyWith(errorMessage: 'Error: $error'));
    }
  }

  Future<void> _runRecipeMutation(Recipe recipe, String successMessage) async {
    try {
      await _recipeRepository.updateRecipe(recipe);
      emit(state.copyWith(actionMessage: successMessage, clearError: true));
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
