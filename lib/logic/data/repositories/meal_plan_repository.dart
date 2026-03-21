import 'package:rxdart/rxdart.dart';

import 'package:reciplan3/logic/core/models/day_plan.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/planned_meal.dart';
import 'package:reciplan3/logic/core/models/week_plan.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/logic/data/daos/day_dao.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';

class MealPlanRepository {
  final DayDao _dayDao;

  MealPlanRepository(this._dayDao);

  Stream<WeekPlan> watchWeekPlan() {
    final dayStreams = List.generate(7, (index) {
      final dayId = index + 1;
      return _dayDao.watchDay(dayId).switchMap((_) {
        return _dayDao.getRecipesForDay(dayId).map((recipes) {
          return DayPlan(
            dayId: dayId,
            dayName: MyUtils.getDayName(dayId),
            meals: _mapMeals(recipes),
          );
        });
      });
    });

    return Rx.combineLatestList(dayStreams).map((days) => WeekPlan(days: days));
  }

  Future<void> assignRecipe({
    required int dayId,
    required MealSlot slot,
    required int recipeId,
  }) {
    switch (slot) {
      case MealSlot.breakfast:
        return _dayDao.updateBreakfast(dayId, recipeId);
      case MealSlot.lunch:
        return _dayDao.updateLunch(dayId, recipeId);
      case MealSlot.dinner:
        return _dayDao.updateDinner(dayId, recipeId);
    }
  }

  Future<void> clearWeekPlan() {
    return _dayDao.clearPlans();
  }

  List<PlannedMeal> _mapMeals(List<Recipe> recipes) {
    final placeholders = <MealSlot, Recipe>{
      MealSlot.breakfast: const Recipe(
        id: 0,
        name: 'Breakfast not Set',
        mins: 0,
        numIngredients: 0,
        direction: '',
        ingredients: '',
        imageUrl: '',
        collection: false,
        favorite: false,
        mealType: 4,
        userCreated: false,
        videoLink: '',
      ),
      MealSlot.lunch: const Recipe(
        id: 1,
        name: 'Lunch not Set',
        mins: 0,
        numIngredients: 0,
        direction: '',
        ingredients: '',
        imageUrl: '',
        collection: false,
        favorite: false,
        mealType: 4,
        userCreated: false,
        videoLink: '',
      ),
      MealSlot.dinner: const Recipe(
        id: 2,
        name: 'Dinner not Set',
        mins: 0,
        numIngredients: 0,
        direction: '',
        ingredients: '',
        imageUrl: '',
        collection: false,
        favorite: false,
        mealType: 4,
        userCreated: false,
        videoLink: '',
      ),
    };

    final orderedRecipes = List<Recipe>.from(recipes);
    while (orderedRecipes.length < 3) {
      orderedRecipes.add(placeholders[MealSlot.values[orderedRecipes.length]]!);
    }

    return [
      PlannedMeal(slot: MealSlot.breakfast, recipe: orderedRecipes[0]),
      PlannedMeal(slot: MealSlot.lunch, recipe: orderedRecipes[1]),
      PlannedMeal(slot: MealSlot.dinner, recipe: orderedRecipes[2]),
    ];
  }
}
