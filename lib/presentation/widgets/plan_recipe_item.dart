import 'package:flutter/material.dart';
import 'package:reciplan3/logic/core/models/meal.dart';

import 'network_image_with_placeholder.dart';

//Dismissible item representing a recipe in a daily meal plan
class PlanRecipeItem extends StatelessWidget {
  final int recipeId;
  final String name;
  final MealSlot? mealType;
  final String imageUrl;

  const PlanRecipeItem({
    super.key,
    required this.name,
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
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Left Column: Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 85, 85, 85)),
                ),
                if (mealType != null) ...[
                  SizedBox(height: 5),
                  Text(
                    mealType!.label.toLowerCase(),
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
                : ReciplanImage(
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
