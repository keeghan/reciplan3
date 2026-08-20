import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'package:reciplan3/presentation/widgets/adaptive_recipe_card.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';
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
              return const AppEmptyState(
                icon: Icons.favorite_border,
                title: 'No favorites yet',
                message:
                    'Tap the heart on a recipe you would love to make again.',
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
                    onOpen: () {
                      Navigator.push(
                        context,
                        AppRoute.build(
                            context, DirectionsScreen(recipe: recipe)),
                      );
                    },
                    onFavorite: () {
                      if (context
                          .read<AppSettingsCubit>()
                          .state
                          .hapticsEnabled) {
                        HapticFeedback.selectionClick();
                      }
                      context.read<FavoritesCubit>().toggleFavorite(recipe);
                    },
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
