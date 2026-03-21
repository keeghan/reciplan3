import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/presentation/widgets/favorite_recipe_card.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/logic/recipes/favorites_cubit.dart';
import 'package:reciplan3/logic/recipes/favorites_state.dart';
import 'directions_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesCubit(
        context.read<RecipeRepository>(),
      )..watchFavorites(),
      child: const _FavoriteView(),
    );
  }
}

class _FavoriteView extends StatelessWidget {
  const _FavoriteView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesCubit, FavoritesState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.actionMessage != current.actionMessage,
      listener: (context, state) {
        final message = state.errorMessage ?? state.actionMessage;
        if (message != null) {
          MyUtils.showSnackBar(context, message);
          context.read<FavoritesCubit>().clearAction();
        }
      },
      child: Scaffold(
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state.isLoading && state.recipes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null && state.recipes.isEmpty) {
              return Center(child: Text(state.errorMessage!));
            }

            if (state.isEmpty) {
              return const Center(child: Text('No favorite recipes yet.'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: state.recipes.length,
              itemBuilder: (context, index) {
                final recipe = state.recipes[index];
                return FavoriteRecipeCard(
                  onDirectionPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DirectionsScreen(recipe: recipe),
                      ),
                    );
                  },
                  onFavoriteClicked: () {
                    context.read<FavoritesCubit>().toggleFavorite(recipe);
                  },
                  name: recipe.name,
                  isFavorite: recipe.favorite,
                  description: '${recipe.mins} mins | ${recipe.numIngredients} ingredients',
                  imageUrl: recipe.imageUrl,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
