import 'package:equatable/equatable.dart';

import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'meal.dart';

class PlannedMeal extends Equatable {
  final MealSlot slot;
  final Recipe recipe;

  const PlannedMeal({
    required this.slot,
    required this.recipe,
  });

  @override
  List<Object?> get props => [slot, recipe];
}
