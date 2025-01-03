import 'package:flutter/material.dart';
import 'package:reciplan3/ui/recipe/directions_screen.dart';
import 'package:reciplan3/util/utils.dart';

import '../../main.dart';
import '../../recipe_viewmodel.dart';
import '../widgets/collection_recipe_card.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CollectionManagementScreenState();
}

class _CollectionManagementScreenState extends State<CollectionScreen> {
  late RecipeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator.get<RecipeViewModel>();
    _loadRecipes();

    _viewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _loadRecipes() {
    _viewModel.loadCollectionRecipes();
  }

  @override
  void dispose() {
    _viewModel.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  //Recipes part of Collection
  //implement favorites
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: _viewModel.collections.length,
          itemBuilder: (context, index) {
            final recipe = _viewModel.collections[index];
            return CollectionRecipeCard(
              onDirectionPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DirectionsScreen(
                            recipe: recipe,
                          )),
                );
              },
              onFavoriteClicked: () {
                final updatedRecipe =
                    recipe.copyWith(favorite: !recipe.favorite);
                _viewModel.updateRecipe(updatedRecipe);
                String msg = updatedRecipe.favorite
                    ? 'added to favorite'
                    : 'removed from favorite';
                MyUtils.showSnackBar(context, msg);
              },
              title: recipe.name,
              isFavorite: recipe.favorite,
              description:
                  '${recipe.mins} mins | ${recipe.numIngredients} ingredients',
              imageUrl: recipe.imageUrl,
            );
          }),
    );
  }
}
