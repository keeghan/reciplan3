import 'package:flutter/material.dart';
import 'package:reciplan3/ui/widgets/plan_recipe_item.dart';

import '../../data/entities/recipe.dart';
import '../../util/util.dart';

//Dismissible item representing a recipe in a daily meal plan
class PlanDayItem extends StatelessWidget {
  final int dayId;
  final List<Recipe> dayRecipes;
  final VoidCallback onEditDayPlanPressed;
  //pass recipeId and mealtype up to planPage to be remove from day
  final Function(int recipeId, int mealType) onRecipeSwiped;

  const PlanDayItem({
    super.key,
    required this.dayRecipes,
    required this.onEditDayPlanPressed,
    required this.dayId,
    required this.onRecipeSwiped,
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
                  getDayName(dayId),
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
                  recipeName: recipe.name,
                  mealType: recipe.mealType,
                  imageUrl: recipe.imageUrl,
                  recipeId: recipe.id,
                  onRecipeSwiped: () =>
                      onRecipeSwiped(recipe.id, recipe.mealType),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
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
