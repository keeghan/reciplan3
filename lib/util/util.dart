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
      content: Text(message),
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
