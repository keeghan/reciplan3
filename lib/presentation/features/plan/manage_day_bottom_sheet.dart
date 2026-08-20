import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/presentation/widgets/plan_recipe_item.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/logic/plan/manage_day_cubit.dart';
import 'package:reciplan3/logic/plan/manage_day_state.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';

class ManageDaySheet extends StatelessWidget {
  final int dayId;

  const ManageDaySheet({
    super.key,
    required this.dayId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageDayCubit(
        context.read<RecipeRepository>(),
        context.read<MealPlanRepository>(),
      )..load(MealSlot.breakfast),
      child: _ManageDayView(dayId: dayId),
    );
  }
}

class _ManageDayView extends StatelessWidget {
  final int dayId;

  const _ManageDayView({
    required this.dayId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageDayCubit, ManageDayState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.actionMessage != current.actionMessage,
      listener: (context, state) {
        final message = state.errorMessage ?? state.actionMessage;
        if (message != null) {
          MyUtils.showSnackBar(context, message);
          context.read<ManageDayCubit>().clearAction();
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: AppSectionHeader(
              title: 'Choose a meal',
              subtitle: 'Pick a slot, then select a recipe.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<ManageDayCubit, ManageDayState>(
              buildWhen: (previous, current) =>
                  previous.selectedSlot != current.selectedSlot,
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<MealSlot>(
                    showSelectedIcon: false,
                    segments: [
                      for (final slot in MealSlot.values)
                        ButtonSegment(value: slot, label: Text(slot.label)),
                    ],
                    selected: {state.selectedSlot},
                    onSelectionChanged: (selection) =>
                        context.read<ManageDayCubit>().load(selection.single),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<ManageDayCubit, ManageDayState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.errorMessage != null && state.recipes.isEmpty) {
                    return Center(child: Text(state.errorMessage!));
                  }

                  if (state.isEmpty) {
                    final label = state.selectedSlot.label.toLowerCase();
                    return Center(
                      child: Text(
                          'Add some $label recipes to your collection first'),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = state.recipes[index];
                      return AppEntrance(
                        index: index,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            AppDesignTokens.radius12,
                          ),
                          onTap: () {
                            if (context
                                .read<AppSettingsCubit>()
                                .state
                                .hapticsEnabled) {
                              HapticFeedback.selectionClick();
                            }
                            context.read<ManageDayCubit>().assignRecipe(
                                  dayId: dayId,
                                  recipe: recipe,
                                );
                          },
                          child: PlanRecipeItem(
                            name: recipe.name,
                            mealType: null,
                            imageUrl: recipe.imageUrl,
                            recipeId: recipe.id!,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
