import 'package:equatable/equatable.dart';

import 'meal.dart';

class RecipeImportItem extends Equatable {
  final String name;
  final int mins;
  final int numIngredients;
  final String direction;
  final String ingredients;
  final String imageUrl;
  final bool collection;
  final bool favorite;
  final MealType mealType;
  final bool userCreated;
  final String videoLink;

  const RecipeImportItem({
    required this.name,
    required this.mins,
    required this.numIngredients,
    required this.direction,
    required this.ingredients,
    required this.imageUrl,
    required this.collection,
    required this.favorite,
    required this.mealType,
    required this.userCreated,
    required this.videoLink,
  });

  @override
  List<Object?> get props => [
        name,
        mins,
        numIngredients,
        direction,
        ingredients,
        imageUrl,
        collection,
        favorite,
        mealType,
        userCreated,
        videoLink,
      ];
}
