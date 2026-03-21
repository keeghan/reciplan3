import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
import 'package:reciplan3/logic/plan/meal_plan_state.dart';

class MealPlanCubit extends Cubit<MealPlanState> {
  final MealPlanRepository _mealPlanRepository;
  StreamSubscription? _subscription;

  MealPlanCubit(this._mealPlanRepository) : super(const MealPlanState());

  void watchPlan() {
    emit(state.copyWith(isLoading: true, clearError: true, clearAction: true));
    _subscription?.cancel();
    _subscription = _mealPlanRepository.watchWeekPlan().listen(
      (weekPlan) {
        emit(
          state.copyWith(
            isLoading: false,
            weekPlan: weekPlan,
            clearError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Error: $error'));
      },
    );
  }

  Future<void> clearWeekPlan() async {
    try {
      await _mealPlanRepository.clearWeekPlan();
      emit(state.copyWith(actionMessage: 'Plans cleared', clearError: true));
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
