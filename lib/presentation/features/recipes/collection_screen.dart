import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/presentation/widgets/collection_recipe_card.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/logic/recipes/collection_cubit.dart';
import 'package:reciplan3/logic/recipes/collection_state.dart';
import 'directions_screen.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollectionCubit(
        context.read<RecipeRepository>(),
      )..watchCollection(),
      child: const _CollectionView(),
    );
  }
}

class _CollectionView extends StatelessWidget {
  const _CollectionView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollectionCubit, CollectionState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.actionMessage != current.actionMessage,
      listener: (context, state) {
        final message = state.errorMessage ?? state.actionMessage;
        if (message != null) {
          MyUtils.showSnackBar(context, message);
          context.read<CollectionCubit>().clearAction();
        }
      },
      child: Scaffold(
        body: BlocBuilder<CollectionCubit, CollectionState>(
          builder: (context, state) {
            if (state.isLoading && state.recipes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null && state.recipes.isEmpty) {
              return Center(child: Text(state.errorMessage!));
            }

            if (state.isEmpty) {
              return const Center(child: Text('No recipes in your collection.'));
            }

            return ListView.builder(
              itemCount: state.recipes.length,
              itemBuilder: (context, index) {
                final recipe = state.recipes[index];
                return CollectionRecipeCard(
                  onDirectionPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DirectionsScreen(recipe: recipe),
                      ),
                    );
                  },
                  onFavoriteClicked: () {
                    context.read<CollectionCubit>().toggleFavorite(recipe);
                  },
                  title: recipe.name,
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
