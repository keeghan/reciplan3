import 'package:flutter/material.dart';
import 'package:reciplan3/ui/widgets/plan_recipe_item.dart';
import 'package:reciplan3/util/util.dart';

import '../../main.dart';
import '../../plan_viewmodel.dart';
import '../../recipe_viewmodel.dart';

//Screen to enable user add recipes to various days
class ManageDayScreen extends StatefulWidget {
  final int dayId;

  const ManageDayScreen({super.key, required this.dayId});

  @override
  State<ManageDayScreen> createState() => _ManageDayScreenState();
}

class _ManageDayScreenState extends State<ManageDayScreen> {
  late RecipeViewModel _recipeViewModel;
  late PlanViewModel _planViewModel;
  RecipeType _currentType = RecipeType.breakfastCollection;

  @override
  void initState() {
    super.initState();
    _recipeViewModel = locator.get<RecipeViewModel>();
    _planViewModel = locator.get<PlanViewModel>();
    _loadRecipes();
  }

  void _loadRecipes() {
    _recipeViewModel.loadMealTypeRecipes(_currentType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${getDayName(widget.dayId)} Meals'),
      ),
      body: Column(
        children: [
          // Meal type selection buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentType = RecipeType.breakfastCollection;
                    _loadRecipes();
                  });
                },
                style: _currentType == RecipeType.breakfastCollection
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      )
                    : null,
                child: const Text('Breakfast'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentType = RecipeType.lunchCollection;
                    _loadRecipes();
                  });
                },
                style: _currentType == RecipeType.lunchCollection
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      )
                    : null,
                child: const Text('Lunch'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentType = RecipeType.dinnerCollection;
                    _loadRecipes();
                  });
                },
                style: _currentType == RecipeType.dinnerCollection
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      )
                    : null,
                child: const Text('Dinner'),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Recipe list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListenableBuilder(
                listenable: _recipeViewModel,
                builder: (context, child) {
                  if (_recipeViewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_recipeViewModel.error != null) {
                    return Center(child: Text(_recipeViewModel.error!));
                  }

                  final recipes = _recipeViewModel.recipes;
                  final msg = '${_currentType.toString().split('.').last}s';

                  if (recipes.isEmpty) {
                    return Center(
                        child: Text('Add some $msg to your collection first'));
                  }

                  return ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        //recipe item when clicked will assign that recipe to the day
                        return InkWell(
                          onTap: () async {
                            await _planViewModel.addRecipeToDay(
                                widget.dayId, recipe.mealType, recipe.id);
                            String msg = _planViewModel.isSuccess
                                ? "${recipe.name} added"
                                : _planViewModel.error!;
                            showSnackBar(context, msg);
                          },
                          //using -1 to represent no need to display mealtype
                          child: PlanRecipeItem(
                            recipeName: recipe.name,
                            mealType: -1,
                            imageUrl: recipe.imageUrl,
                            recipeId: recipe.id,
                          ),
                        );
                      });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
