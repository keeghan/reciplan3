import 'package:flutter/material.dart';

import '../../util/util.dart';
import 'network_image_with_placeholder.dart';

//Dismissible item representing a recipe in a daily meal plan
class PlanRecipeItem extends StatelessWidget {
  final int recipeId;
  final String recipeName;
  final int mealType;
  final String imageUrl;

  const PlanRecipeItem({
    super.key,
    required this.recipeName,
    required this.mealType,
    required this.imageUrl,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      padding: EdgeInsets.fromLTRB(10, 4, 4, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Column: Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipeName,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 62, 62, 62)),
                ),
                if (mealType != -1) ...[
                  //no recipe type is -1
                  SizedBox(height: 5),
                  Text(
                    getMealType(mealType),
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Right Column: Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: recipeId < 3
                ? Image.asset(
                    'assets/images/image_placeholder.jpg',
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  )
                : NetworkImageWithPlaceholder(
                    imageUrl: imageUrl,
                    height: 60,
                    width: 60,
                  ),
          ),
        ],
      ),
    );
  }
}

//match day with id
String getMealType(int mealType) {
  switch (mealType) {
    case MealType.breakfast:
      return 'breakfast';
    case MealType.lunch:
      return 'lunch';
    case MealType.dinner:
      return 'dinner';
    default:
      throw Exception("Invalid Recipe MealType");
  }
}
