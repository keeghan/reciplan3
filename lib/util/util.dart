import 'package:flutter/material.dart';

class MealType {
  static const int breakfast = 0;
  static const int lunch = 1;
  static const int dinner = 2;
  static const int snack = 3;
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceTint,
      content: Text(message, textAlign: TextAlign.center),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    ),
  );
}

class ReciplanCustomColors {
  static const appBarColor = Color.fromARGB(255, 5, 91, 8);
}

class DayIds {
  static const int sunday = 1;
  static const int monday = 2;
  static const int tuesday = 3;
  static const int wednesday = 4;
  static const int thursday = 5;
  static const int friday = 6;
  static const int saturday = 7;
}

//match day with id
String getDayName(int dayId) {
  switch (dayId) {
    case DayIds.sunday:
      return 'Sunday';
    case DayIds.monday:
      return 'Monday';
    case DayIds.tuesday:
      return 'Tuesday';
    case DayIds.wednesday:
      return 'Wednesday';
    case DayIds.thursday:
      return 'Thursday';
    case DayIds.friday:
      return 'Friday';
    case DayIds.saturday:
      return 'Saturday';
    default:
      throw Exception("Invalid Day Id");
  }
}
