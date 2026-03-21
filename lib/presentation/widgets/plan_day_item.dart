import 'package:flutter/material.dart';
import 'package:reciplan3/logic/core/models/day_plan.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/presentation/widgets/plan_recipe_item.dart';

//Dismissible item representing a recipe in a daily meal plan
class PlanDayItem extends StatelessWidget {
  final DayPlan dayPlan;
  final VoidCallback onEditDayPlanPressed;

  const PlanDayItem({
    super.key,
    required this.dayPlan,
    required this.onEditDayPlanPressed,
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
                  dayPlan.dayName,
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
            itemCount: dayPlan.meals.length,
            itemBuilder: (context, index) {
              final meal = dayPlan.meals[index];
              final recipe = meal.recipe;
              return KeyedSubtree(
                child: PlanRecipeItem(
                  name: recipe.name,
                  mealType: recipe.mealTypeEnum == MealType.missing ? null : meal.slot,
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
