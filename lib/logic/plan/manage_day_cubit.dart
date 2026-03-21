import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/plan/manage_day_state.dart';

class ManageDayCubit extends Cubit<ManageDayState> {
  final RecipeRepository _recipeRepository;
  final MealPlanRepository _mealPlanRepository;
  StreamSubscription<List<Recipe>>? _subscription;

  ManageDayCubit(
    this._recipeRepository,
    this._mealPlanRepository,
  ) : super(const ManageDayState());

  void load(MealSlot slot) {
    emit(
      state.copyWith(
        selectedSlot: slot,
        isLoading: true,
        clearError: true,
        clearAction: true,
      ),
    );
    _subscription?.cancel();
    _subscription = _recipeRepository
        .watchCollectionRecipesByMealType(_toMealType(slot))
        .listen(
      (recipes) {
        emit(
          state.copyWith(
            selectedSlot: slot,
            isLoading: false,
            recipes: recipes,
            clearError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Error: $error'));
      },
    );
  }

  Future<void> assignRecipe({
    required int dayId,
    required Recipe recipe,
  }) async {
    emit(state.copyWith(isAssigning: true, clearError: true, clearAction: true));
    try {
      await _mealPlanRepository.assignRecipe(
        dayId: dayId,
        slot: state.selectedSlot,
        recipeId: recipe.id!,
      );
      emit(
        state.copyWith(
          isAssigning: false,
          actionMessage: '${recipe.name} added',
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isAssigning: false, errorMessage: 'Error: $error'));
    }
  }

  void clearAction() {
    emit(state.copyWith(clearAction: true));
  }

  MealType _toMealType(MealSlot slot) {
    switch (slot) {
      case MealSlot.breakfast:
        return MealType.breakfast;
      case MealSlot.lunch:
        return MealType.lunch;
      case MealSlot.dinner:
        return MealType.dinner;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
