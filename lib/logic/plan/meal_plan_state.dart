import 'package:equatable/equatable.dart';

import 'package:reciplan3/logic/core/models/week_plan.dart';

class MealPlanState extends Equatable {
  final bool isLoading;
  final WeekPlan? weekPlan;
  final String? errorMessage;
  final String? actionMessage;

  const MealPlanState({
    this.isLoading = false,
    this.weekPlan,
    this.errorMessage,
    this.actionMessage,
  });

  MealPlanState copyWith({
    bool? isLoading,
    WeekPlan? weekPlan,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
  }) {
    return MealPlanState(
      isLoading: isLoading ?? this.isLoading,
      weekPlan: weekPlan ?? this.weekPlan,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, weekPlan, errorMessage, actionMessage];
}
