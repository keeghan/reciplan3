import 'package:flutter/material.dart';
import 'package:reciplan3/ui/widgets/plan_recipe_item.dart';

import '../../data/entities/recipe.dart';
import '../../util/utils.dart';

//Dismissible item representing a recipe in a daily meal plan
class PlanDayItem extends StatelessWidget {
  final int dayId;
  final List<Recipe> dayRecipes;
  final VoidCallback onEditDayPlanPressed;

  const PlanDayItem({
    super.key,
    required this.dayRecipes,
    required this.onEditDayPlanPressed,
    required this.dayId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: EdgeInsets.all(0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Text(
                  MyUtils.getDayName(dayId),
                  style: TextStyle(
                    fontSize: 20, // Example size, adjust as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: TextButton(
                    onPressed: onEditDayPlanPressed,
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        fontSize: 18, // Example size, adjust as needed
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
            ],
          ),
          //recipes
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) {
              final recipe = dayRecipes[index];
              return KeyedSubtree(
                child: PlanRecipeItem(
                  name: recipe.name,
                  mealType: (recipe.mealType == MealType.missing) ? -1 : recipe.mealType,
                  imageUrl: recipe.imageUrl,
                  recipeId: recipe.id!,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
