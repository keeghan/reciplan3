import 'package:flutter/material.dart';
import 'package:reciplan3/logic/core/models/day_plan.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/presentation/widgets/plan_recipe_item.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';

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
    return Card(
      margin: const EdgeInsets.only(bottom: AppDesignTokens.space16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dayPlan.dayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Edit ${dayPlan.dayName}',
                  onPressed: onEditDayPlanPressed,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: dayPlan.meals.length,
            itemBuilder: (context, index) {
              final meal = dayPlan.meals[index];
              final recipe = meal.recipe;
              return KeyedSubtree(
                key:
                    ValueKey('${dayPlan.dayId}-${meal.slot.name}-${recipe.id}'),
                child: PlanRecipeItem(
                  name: recipe.name,
                  mealType: recipe.mealTypeEnum == MealType.missing
                      ? null
                      : meal.slot,
                  imageUrl: recipe.imageUrl,
                  recipeId: recipe.id!,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
