import 'package:flutter/material.dart';
import 'package:reciplan3/ui/recipe/directions_screen.dart';

import '../../main.dart';
import '../../recipe_viewmodel.dart';
import '../widgets/favorite_recipe_card.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late RecipeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator.get<RecipeViewModel>();
    _viewModel.loadFavoriteRecipes();

    _viewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
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
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _viewModel.favorites.length,
        itemBuilder: (context, index) {
          final recipe = _viewModel.favorites[index];
          return FavoriteRecipeCard(
            onDirectionPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectionsScreen(
                    recipe: recipe,
                  ),
                ),
              );
            },
            onFavoriteClicked: () {
              final updatedRecipe = recipe.copyWith(favorite: !recipe.favorite);
              _viewModel.updateRecipe(updatedRecipe);
            },
            name: recipe.name,
            isFavorite: recipe.favorite,
            description:
                '${recipe.mins} mins | ${recipe.numIngredients} ingredients',
            imageUrl: recipe.imageUrl,
          );
        },
      ),
    );
  }
}
