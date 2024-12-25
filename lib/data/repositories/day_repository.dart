import '../../util/util.dart';
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

  // Update meal slots
  Future<void> updateDayMeal(int dayId, int recipeId, int mealType) async {
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

  // Add a new recipe
  Future<void> addRecipe(Recipe recipe) async {
    await _dayDao.insertRecipe(recipe);
  }

  // Get all recipes for a specific day
  Future<List<Recipe>> getDayRecipes(int dayId) async {
    return await _dayDao.getRecipesForDay(dayId);
  }
}
