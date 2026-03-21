import 'package:equatable/equatable.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';

class ManageDayState extends Equatable {
  final MealSlot selectedSlot;
  final bool isLoading;
  final bool isAssigning;
  final List<Recipe> recipes;
  final String? errorMessage;
  final String? actionMessage;

  const ManageDayState({
    this.selectedSlot = MealSlot.breakfast,
    this.isLoading = false,
    this.isAssigning = false,
    this.recipes = const [],
    this.errorMessage,
    this.actionMessage,
  });

  bool get isEmpty => !isLoading && recipes.isEmpty && errorMessage == null;

  ManageDayState copyWith({
    MealSlot? selectedSlot,
    bool? isLoading,
    bool? isAssigning,
    List<Recipe>? recipes,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
  }) {
    return ManageDayState(
      selectedSlot: selectedSlot ?? this.selectedSlot,
      isLoading: isLoading ?? this.isLoading,
      isAssigning: isAssigning ?? this.isAssigning,
      recipes: recipes ?? this.recipes,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [selectedSlot, isLoading, isAssigning, recipes, errorMessage, actionMessage];
}
