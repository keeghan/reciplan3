import 'package:floor/floor.dart';

import '../entities/day.dart';
import '../entities/recipe.dart';

@dao
abstract class DayDao {
  @Query('SELECT * FROM day_table WHERE id = :dayId')
  Future<Day?> getDay(int dayId);

  @Query('SELECT * FROM day_table')
  Future<List<Day>> getAllDays();

  @Query('UPDATE day_table SET breakfast = :recipeId WHERE id = :dayId')
  Future<void> updateBreakfast(int dayId, int recipeId);

  @Query('UPDATE day_table SET lunch = :recipeId WHERE id = :dayId')
  Future<void> updateLunch(int dayId, int recipeId);

  @Query('UPDATE day_table SET dinner = :recipeId WHERE id = :dayId')
  Future<void> updateDinner(int dayId, int recipeId);

  @Query('UPDATE day_table SET snack = :recipeId WHERE id = :dayId')
  Future<void> updateSnack(int dayId, int recipeId);

  @insert
  Future<void> insertDay(Day day);

  @insert
  Future<void> insertRecipe(Recipe recipe);

  @update
  Future<void> updateDay(Day day);

  //Other methods
  @Query('''
    SELECT r.* FROM recipe_table r
    INNER JOIN day_table d ON 
      r.id = d.breakfast OR 
      r.id = d.lunch OR 
      r.id = d.dinner
    WHERE d.id = :dayId
    ORDER BY CASE r.id 
      WHEN d.breakfast THEN 1
      WHEN d.lunch THEN 2
      WHEN d.dinner THEN 3
    END
  ''')
  Stream<List<Recipe>> getRecipesForDay(int dayId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertDays(List<Day> days);

  //Appbar Menu Commands
  @Query("UPDATE recipe_table SET collection = 'false', favorite = 'false' ")
  Future<void> clearCollection();

  @Query("UPDATE recipe_table SET favorite = 'false' ")
  Future<void> clearFavorite();

  @Query("UPDATE day_table SET breakfast  = '0', lunch = '1', dinner = '2' ")
  Future<void> clearPlans();
}
