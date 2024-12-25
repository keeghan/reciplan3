import 'package:flutter/material.dart';

import '../../main.dart';
import '../../recipe_viewmodel.dart';
import '../widgets/recipe_card.dart';

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
    print("loaded");
    print(_viewModel.recipes.length.toString());

    // Listen to changes in viewModel
    _viewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _loadRecipes() {
    switch (widget.collectionId) {
      case 'Breakfast':
        _viewModel.loadBreakfastRecipes();
        break;
      case 'Lunch':
        _viewModel.loadLunchRecipes();
        break;
      case 'Dinner':
        _viewModel.loadDinnerRecipes();
        break;
      default:
        _viewModel.loadSnackRecipes();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionId),
      ),
      body:
          //Center(child: Text(_viewModel.recipes.length.toString())
          ListView.builder(
        itemCount: _viewModel.recipes.length,
        itemBuilder: (context, index) {
          final recipe = _viewModel.recipes[index];
          return RecipeCard(
            title: recipe.name,
            description:
                '${recipe.mins} mins | ${recipe.numIngredients} ingredients',
            imageUrl: recipe.imageUrl,
          );
        },
      ),
    );
  }
}
