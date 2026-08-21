import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/presentation/widgets/adaptive_recipe_card.dart';
import 'package:reciplan3/presentation/widgets/adaptive_recipe_browser.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/logic/recipes/collection_cubit.dart';
import 'package:reciplan3/logic/recipes/collection_state.dart';

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
              return const AppEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'Your collection is ready to grow',
                message: 'Add recipes from Explore to keep them close at hand.',
              );
            }

            return AdaptiveRecipeBrowser(
              recipes: state.recipes,
              storageKey: 'collection-recipes',
              cardBuilder: (context, recipe, onOpen, selected) {
                return AppEntrance(
                  child: AdaptiveRecipeCard(
                    recipe: recipe,
                    selected: selected,
                    onOpen: onOpen,
                    onFavorite: () {
                      if (context.read<AppSettingsCubit>().state.hapticsEnabled) {
                        HapticFeedback.selectionClick();
                      }
                      context.read<CollectionCubit>().toggleFavorite(recipe);
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
