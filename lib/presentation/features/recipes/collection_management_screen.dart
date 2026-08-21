import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/recipes/recipe_catalog_cubit.dart';
import 'package:reciplan3/logic/recipes/recipe_catalog_state.dart';
import 'package:reciplan3/presentation/widgets/adaptive_recipe_browser.dart';
import 'package:reciplan3/presentation/widgets/adaptive_recipe_card.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';
import 'package:reciplan3/util/utils.dart';

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

            return AdaptiveRecipeBrowser(
              recipes: state.recipes,
              storageKey: 'catalog-$title',
              cardBuilder: (context, recipe, onOpen, selected) {
                return AppEntrance(
                  child: AdaptiveRecipeCard(
                    recipe: recipe,
                    selected: selected,
                    onCollection: () {
                      if (context.read<AppSettingsCubit>().state.hapticsEnabled) {
                        HapticFeedback.selectionClick();
                      }
                      context.read<RecipeCatalogCubit>().toggleCollection(
                            recipe,
                            !recipe.collection,
                          );
                    },
                    onOpen: onOpen,
                    onDelete: recipe.userCreated
                        ? () => MyUtils.showDeleteConfirmationDialog(
                              context,
                              'Delete recipe?',
                              'This recipe will be permanently removed.',
                              'Delete',
                              () => context.read<RecipeCatalogCubit>().deleteRecipe(recipe),
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
