import 'package:flutter/material.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'network_image_with_placeholder.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final isEmpty = recipeId < 3;
    return AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.state),
      curve: AppMotion.stateCurve,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isEmpty
            ? scheme.surfaceContainerLowest
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        border: Border.all(
          color: isEmpty ? scheme.outlineVariant : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isEmpty
                ? Container(
                    width: 58,
                    height: 58,
                    color: scheme.primaryContainer,
                    child: Icon(
                      Icons.add,
                      color: scheme.onPrimaryContainer,
                    ),
                  )
                : ReciplanImage(
                    imageUrl: imageUrl,
                    height: 58,
                    width: 58,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mealType != null) ...[
                  Text(
                    mealType!.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  isEmpty ? 'Choose a recipe' : name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isEmpty
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
          if (isEmpty)
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
