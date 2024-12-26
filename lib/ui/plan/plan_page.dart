import 'package:flutter/material.dart';

import '../../data/entities/recipe.dart';
import '../../main.dart';
import '../../plan_viewmodel.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late PlanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator.get<PlanViewModel>();
    _loadRecipes();
  }

  void _loadRecipes() {
    // Initiates loading of the recipes. This could be calling the stream or any other method.
    _viewModel.loadWeekRecipes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Map<int, List<Recipe>>>(
        stream: _viewModel.weekRecipesStream, // The stream from your ViewModel
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // If no data or an empty map is returned, show a no data message
            return Center(child: Text('No recipes found.'));
          } else {
            final weekRecipes = snapshot.data!;
            return ListView.builder(
              itemCount: weekRecipes.length,
              itemBuilder: (context, index) {
                final dayId = weekRecipes.keys.elementAt(index);
                final recipes = weekRecipes[dayId];

                return ListTile(
                  title: Text('Day $dayId'),
                  subtitle: Text('Recipes count: ${recipes?.length ?? 0}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
