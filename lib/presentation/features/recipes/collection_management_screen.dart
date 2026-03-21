import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/presentation/widgets/manage_collection_recipe_card.dart';
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
          backgroundColor: ReciplanCustomColors.appBarColor,
          foregroundColor: Colors.white,
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
              return const Center(child: Text('No recipes found.'));
            }

            return ListView.builder(
              itemCount: state.recipes.length,
              itemBuilder: (context, index) {
                final recipe = state.recipes[index];
                return ManageCollectionRecipeCard(
                  recipe: recipe,
                  onCheckPress: () {
                    if (!recipe.collection) {
                      context.read<RecipeCatalogCubit>().toggleCollection(recipe, true);
                    }
                  },
                  onRemovePress: () {
                    if (recipe.collection) {
                      context.read<RecipeCatalogCubit>().toggleCollection(recipe, false);
                    }
                  },
                  onDirectionPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DirectionsScreen(recipe: recipe),
                      ),
                    );
                  },
                  onDeletePress: () {
                    context.read<RecipeCatalogCubit>().deleteRecipe(recipe);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
