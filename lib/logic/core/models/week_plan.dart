import 'package:equatable/equatable.dart';

import 'day_plan.dart';

class WeekPlan extends Equatable {
  final List<DayPlan> days;

  const WeekPlan({
    required this.days,
  });

  @override
  List<Object?> get props => [days];
}
