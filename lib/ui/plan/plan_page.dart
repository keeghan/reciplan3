import 'package:flutter/material.dart';
import 'package:reciplan3/ui/plan/manage_day_screen.dart';
import 'package:reciplan3/ui/widgets/plan_day_item.dart';

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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Map<int, List<Recipe>>>(
        stream: _viewModel.weekRecipesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No recipes found.'));
          } else {
            final weekRecipes = snapshot.data!;

            //day item here
            return ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                final dayId = weekRecipes.keys.elementAt(index);
                final recipes = weekRecipes[dayId];
                return PlanDayItem(
                  dayId: dayId,
                  dayRecipes: recipes!,
                  onEditDayPlanPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageDayScreen(dayId: dayId),
                      ),
                    );
                  },
                  onRecipeSwiped: (int recipeId, int mealType) {
                    _viewModel.clearRecipeInDay(dayId, mealType);
                    // setState(() {print("--------------------set in motion----------------------------");});
                   // Todo: Rebulid only correct planDayItem
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
