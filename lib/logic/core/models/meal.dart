enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  missing,
}

enum MealSlot {
  breakfast,
  lunch,
  dinner,
}

extension MealTypeX on MealType {
  int get dbValue {
    switch (this) {
      case MealType.breakfast:
        return 0;
      case MealType.lunch:
        return 1;
      case MealType.dinner:
        return 2;
      case MealType.snack:
        return 3;
      case MealType.missing:
        return 4;
    }
  }

  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      case MealType.missing:
        return 'Missing';
    }
  }
}

extension MealSlotX on MealSlot {
  String get label {
    switch (this) {
      case MealSlot.breakfast:
        return 'Breakfast';
      case MealSlot.lunch:
        return 'Lunch';
      case MealSlot.dinner:
        return 'Dinner';
    }
  }

  int get placeholderRecipeId {
    switch (this) {
      case MealSlot.breakfast:
        return 0;
      case MealSlot.lunch:
        return 1;
      case MealSlot.dinner:
        return 2;
    }
  }
}

MealType mealTypeFromDbValue(int value) {
  switch (value) {
    case 0:
      return MealType.breakfast;
    case 1:
      return MealType.lunch;
    case 2:
      return MealType.dinner;
    case 3:
      return MealType.snack;
    default:
      return MealType.missing;
  }
}

MealSlot mealSlotFromMealType(MealType mealType) {
  switch (mealType) {
    case MealType.breakfast:
      return MealSlot.breakfast;
    case MealType.lunch:
      return MealSlot.lunch;
    case MealType.dinner:
      return MealSlot.dinner;
    case MealType.snack:
    case MealType.missing:
      throw ArgumentError('Meal type $mealType cannot be mapped to a meal slot.');
  }
}
