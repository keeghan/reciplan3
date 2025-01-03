import 'package:rxdart/rxdart.dart';

import '../../util/utils.dart';
import '../daos/day_dao.dart';
import '../entities/day.dart';
import '../entities/recipe.dart';

class DayRepository {
  final DayDao _dayDao;

  DayRepository(this._dayDao);

  // Get a specific day
  Future<Day?> getDay(int dayId) async {
    return await _dayDao.getDay(dayId);
  }

  Future<List<Day>> getAllDays() async {
    return await _dayDao.getAllDays();
  }

  // Create a new day
  Future<void> createDay(Day day) async {
    await _dayDao.insertDay(day);
  }

  // Update a day, especially for the plan
  Future<void> updateRecipe(Day day) async {
    await _dayDao.updateDay(day);
  }

  // Update day to set new recipe or remove one
  Future<void> updateDayMeal(int dayId, int mealType, int recipeId) async {
    switch (mealType) {
      case MealType.breakfast:
        await _dayDao.updateBreakfast(dayId, recipeId);
        break;
      case MealType.lunch:
        await _dayDao.updateLunch(dayId, recipeId);
        break;
      case MealType.dinner:
        await _dayDao.updateDinner(dayId, recipeId);
        break;
      default:
        await _dayDao.updateSnack(dayId, recipeId);
    }
  }

  //Combine all days into one stream
  Stream<Map<int, List<Recipe>>> getWeekRecipes() {
    final dayStreams = List.generate(7, (dayId) {
      return _dayDao.getRecipesForDay(dayId + 1).map((recipes) {
        return MapEntry(dayId + 1, recipes);
      });
    });

    return Rx.combineLatest<MapEntry<int, List<Recipe>>, Map<int, List<Recipe>>>(
      dayStreams,
      (entries) => Map.fromEntries(entries),
    );
  }

  //Clear all Plans
  Future<void> clearPlans() async {
    _dayDao.clearPlans();
  }
}
