import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/presentation/widgets/plan_recipe_item.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/logic/plan/manage_day_cubit.dart';
import 'package:reciplan3/logic/plan/manage_day_state.dart';

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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: MealSlot.values.map((slot) {
                return BlocBuilder<ManageDayCubit, ManageDayState>(
                  builder: (context, state) {
                    final isSelected = state.selectedSlot == slot;
                    return ElevatedButton(
                      onPressed: () => context.read<ManageDayCubit>().load(slot),
                      style: isSelected
                          ? ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.orange,
                            )
                          : null,
                      child: Text(slot.label),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
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
                        child: Text('Add some $label recipes to your collection first'),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = state.recipes[index];
                        return InkWell(
                          onTap: () {
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
      ),
    );
  }
}
