import 'package:equatable/equatable.dart';

import 'meal.dart';

class RecipeDraft extends Equatable {
  final String name;
  final int mins;
  final int numIngredients;
  final String direction;
  final String ingredients;
  final String imagePath;
  final bool collection;
  final bool favorite;
  final MealType mealType;
  final String videoLink;

  const RecipeDraft({
    required this.name,
    required this.mins,
    required this.numIngredients,
    required this.direction,
    required this.ingredients,
    required this.imagePath,
    required this.collection,
    required this.favorite,
    required this.mealType,
    required this.videoLink,
  });

  @override
  List<Object?> get props => [
        name,
        mins,
        numIngredients,
        direction,
        ingredients,
        imagePath,
        collection,
        favorite,
        mealType,
        videoLink,
      ];
}
