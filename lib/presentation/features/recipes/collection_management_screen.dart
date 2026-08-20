import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'package:reciplan3/presentation/widgets/adaptive_recipe_card.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/logic/recipes/recipe_catalog_cubit.dart';
import 'package:reciplan3/logic/recipes/recipe_catalog_state.dart';
import 'directions_screen.dart';

class CollectionManagementScreen extends StatelessWidget {
  final String title;
  final MealType mealType;

  const CollectionManagementScreen({
    super.key,
    required this.title,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipeCatalogCubit(
        context.read<RecipeRepository>(),
      )..watchMealType(mealType),
      child: _CollectionManagementView(title: title),
    );
  }
}

class _CollectionManagementView extends StatelessWidget {
  final String title;

  const _CollectionManagementView({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipeCatalogCubit, RecipeCatalogState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.actionMessage != current.actionMessage,
      listener: (context, state) {
        final message = state.errorMessage ?? state.actionMessage;
        if (message != null) {
          MyUtils.showSnackBar(context, message);
          context.read<RecipeCatalogCubit>().clearAction();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: BlocBuilder<RecipeCatalogCubit, RecipeCatalogState>(
          builder: (context, state) {
            if (state.isLoading && state.recipes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null && state.recipes.isEmpty) {
              return Center(child: Text(state.errorMessage!));
            }

            if (state.isEmpty) {
              return const AppEmptyState(
                icon: Icons.search_off,
                title: 'No recipes found',
                message: 'Add a new recipe and it will appear here.',
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppDesignTokens.space16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                childAspectRatio: 0.78,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.recipes.length,
              itemBuilder: (context, index) {
                final recipe = state.recipes[index];
                return AppEntrance(
                  index: index,
                  child: AdaptiveRecipeCard(
                    recipe: recipe,
                    onCollection: () {
                      if (context
                          .read<AppSettingsCubit>()
                          .state
                          .hapticsEnabled) {
                        HapticFeedback.selectionClick();
                      }
                      context.read<RecipeCatalogCubit>().toggleCollection(
                            recipe,
                            !recipe.collection,
                          );
                    },
                    onOpen: () {
                      Navigator.push(
                        context,
                        AppRoute.build(
                            context, DirectionsScreen(recipe: recipe)),
                      );
                    },
                    onDelete: recipe.userCreated
                        ? () => MyUtils.showDeleteConfirmationDialog(
                              context,
                              'Delete recipe?',
                              'This recipe will be permanently removed.',
                              'Delete',
                              () => context
                                  .read<RecipeCatalogCubit>()
                                  .deleteRecipe(recipe),
                            )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
