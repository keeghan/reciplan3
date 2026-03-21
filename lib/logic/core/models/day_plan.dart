import 'package:equatable/equatable.dart';

import 'planned_meal.dart';

class DayPlan extends Equatable {
  final int dayId;
  final String dayName;
  final List<PlannedMeal> meals;

  const DayPlan({
    required this.dayId,
    required this.dayName,
    required this.meals,
  });

  @override
  List<Object?> get props => [dayId, dayName, meals];
}
