import 'package:flutter/material.dart';
import '../../main.dart';
import '../../recipe_viewmodel.dart';
import '../widgets/recipe_card.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CollectionManagementScreen extends StatefulWidget {
  final String collectionId;

  const CollectionManagementScreen({super.key, required this.collectionId});

  @override
  State<StatefulWidget> createState() => _CollectionManagementScreenState();
}

class _CollectionManagementScreenState
    extends State<CollectionManagementScreen> {
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
    RecipeType type;
    switch (widget.collectionId) {
      case 'Breakfast':
        type = RecipeType.breakfast;
      case 'Lunch':
        type = RecipeType.lunch;
      case 'Dinner':
        type = RecipeType.dinner;
      default:
        type = RecipeType.snack;
    }
    _viewModel.loadRecipes(type);
  }

  @override
  void dispose() {
    _viewModel.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  //Main ListView with RecipeCards for adding to or removing
  //Recipes from Collection
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionId),
      ),
      body: ListView.builder(
          itemCount: _viewModel.recipes.length,
          itemBuilder: (context, index) {
            final recipe = _viewModel.recipes[index];
            return RecipeCard(
              onCheckPress: () {
                if (recipe.collection) {
                  makeToast("Recipe already in collection");
                  return;
                }
                final updatedRecipe = recipe.copyWith(collection: true);
                _viewModel.updateRecipe(updatedRecipe);
                //Todo: fix, get confirmation from viewmodel
                makeToast("${recipe.name} added");
              },
              onRemovePress: () {
                if (!recipe.collection) {
                  makeToast("Recipe is not in collection");
                  return;
                }
                final updatedRecipe = recipe.copyWith(collection: false);
                _viewModel.updateRecipe(updatedRecipe);
                makeToast("${recipe.name} added");
              },
              title: recipe.name,
              description:
                  '${recipe.mins} mins | ${recipe.numIngredients} ingredients',
              imageUrl: recipe.imageUrl,
            );
          }),
    );
  }
}

makeToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}
