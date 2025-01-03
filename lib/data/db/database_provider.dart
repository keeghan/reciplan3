import 'package:floor/floor.dart';
import 'package:reciplan3/util/yt_links.dart';

import 'data.dart';
import '../../util/utils.dart';
import '../daos/day_dao.dart';
import '../daos/recipe_dao.dart';
import '../entities/day.dart';
import '../entities/recipe.dart';
import 'reciplan_database.dart';

class DatabaseProvider {
  static ReciplanDatabase? _database;
  static RecipeDao? _recipeDao;
  static DayDao? _dayDao;

  static Future<ReciplanDatabase> get database async {
    if (_database != null) {
      return _database!;
    }

    try {
      _database = await $FloorReciplanDatabase
          .databaseBuilder('reciplan_database.db')
          .addCallback(Callback(
        //Prepopulate database
        onCreate: (database, version) async {
          // Insert all recipes first
          for (var recipe in recipes) {
            await database.execute(
              'INSERT INTO recipe_table (id, name, mins, numIngredients, direction, ingredients, imageUrl, collection, favorite, mealType, userCreated, videoLink) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
              [
                recipe.id,
                recipe.name,
                recipe.mins,
                recipe.numIngredients,
                recipe.direction,
                recipe.ingredients,
                recipe.imageUrl,
                recipe.collection ? 1 : 0,
                recipe.favorite ? 1 : 0,
                recipe.mealType,
                recipe.userCreated ? 1 : 0,
                recipe.videoLink
              ],
            );
          }

          // Then insert all days
          for (var day in days) {
            await database.execute(
              'INSERT INTO day_table (id, name, breakfast, lunch, dinner) VALUES (?, ?, ?, ?, ?)',
              [day.id, day.name, day.breakfast, day.lunch, day.dinner],
            );
          }
        },
      )).build();

      _recipeDao = _database!.recipeDao;
      _dayDao = _database!.dayDao;

      return _database!;
    } catch (e) {
      print('Error getting database: $e');
      rethrow;
    }
  }

  static Future<RecipeDao> get recipeDao async {
    if (_recipeDao != null) {
      return _recipeDao!;
    }
    final db = await database;
    _recipeDao = db.recipeDao;
    return _recipeDao!;
  }

  static Future<DayDao> get dayDao async {
    if (_dayDao != null) {
      return _dayDao!;
    }
    final db = await database;
    _dayDao = db.dayDao;
    return _dayDao!;
  }

  //Prepopulate Days Table
  static List<Recipe> recipes = [
    Recipe(
        id: 0,
        name: "Breakfast not Set",
        mins: 0,
        numIngredients: 0,
        direction: "",
        ingredients: " ",
        imageUrl: RecipeImgUrls.missing0,
        collection: false,
        favorite: false,
        mealType: MealType.missing,
        videoLink: RecipeVideoUrls.missing0),
    Recipe(
        id: 1,
        name: "Lunch not Set",
        mins: 0,
        numIngredients: 0,
        direction: "",
        ingredients: " ",
        imageUrl: RecipeImgUrls.missing0,
        collection: false,
        favorite: false,
        mealType: MealType.missing,
        videoLink: RecipeVideoUrls.missing0),
    Recipe(
        id: 2,
        name: "Dinner not Set",
        mins: 0,
        numIngredients: 0,
        direction: "",
        ingredients: " ",
        imageUrl: RecipeImgUrls.missing0,
        collection: false,
        favorite: false,
        mealType: MealType.missing,
        videoLink: RecipeVideoUrls.missing0),
    Recipe(
        id: 3,
        name: "Hausa Kooko",
        mins: 15,
        numIngredients: 6,
        direction: RecipeDirections.hausaKookoDir,
        ingredients: RecipeIngredients.hausaKookoIngredients,
        imageUrl: RecipeImgUrls.hausa_Kooko,
        collection: true,
        favorite: true,
        mealType: MealType.breakfast,
        videoLink: RecipeVideoUrls.hausa_Kooko),
    Recipe(
        id: 4,
        name: "Koose (Spicy Bean Cake)",
        mins: 60,
        numIngredients: 7,
        direction: RecipeDirections.kooseDir,
        ingredients: RecipeIngredients.kooseIngr,
        imageUrl: RecipeImgUrls.koose,
        collection: true,
        favorite: true,
        mealType: MealType.breakfast,
        videoLink: RecipeVideoUrls.koose),
    Recipe(
        id: 5,
        name: "Yam Balls",
        mins: 15,
        numIngredients: 6,
        direction: RecipeDirections.yamBallsDir,
        ingredients: RecipeIngredients.yamBallsIngr,
        imageUrl: RecipeImgUrls.yam_Balls,
        collection: true,
        favorite: true,
        mealType: MealType.snack,
        videoLink: RecipeVideoUrls.yam_Balls),
    Recipe(
        id: 6,
        name: "Kelewele",
        mins: 25,
        numIngredients: 5,
        direction: RecipeDirections.keleweleDir,
        ingredients: RecipeIngredients.keleweleIngr,
        imageUrl: RecipeImgUrls.kelewele,
        collection: false,
        favorite: false,
        mealType: MealType.snack,
        videoLink: RecipeVideoUrls.kelewele),
    Recipe(
        id: 7,
        name: "Fish Stew",
        mins: 40,
        numIngredients: 8,
        direction: RecipeDirections.fishStewDir,
        ingredients: RecipeIngredients.fishStewIngr,
        imageUrl: RecipeImgUrls.fish_Stew,
        collection: false,
        favorite: false,
        mealType: MealType.dinner,
        videoLink: RecipeVideoUrls.fish_Stew),
    Recipe(
        id: 8,
        name: "Omo Tuo",
        mins: 25,
        numIngredients: 3,
        direction: RecipeDirections.omoTuoDir,
        ingredients: RecipeIngredients.omoTuoIngr,
        imageUrl: RecipeImgUrls.omo_Tuo,
        collection: false,
        favorite: false,
        mealType: MealType.dinner,
        videoLink: RecipeVideoUrls.omo_Tuo),
    Recipe(
        id: 9,
        name: "BanKye (Agble) Krakro",
        mins: 20,
        numIngredients: 4,
        direction: RecipeDirections.bankyeKrakroDir,
        ingredients: RecipeIngredients.bankyeKrakroIngr,
        imageUrl: RecipeImgUrls.bankye_kakro,
        collection: false,
        favorite: false,
        mealType: MealType.snack,
        videoLink: RecipeVideoUrls.bankye_kakro),
    Recipe(
        id: 10,
        name: "Nkatie Cake",
        mins: 15,
        numIngredients: 2,
        direction: RecipeDirections.nkatieCakeDir,
        ingredients: RecipeIngredients.nkatieCakeIngr,
        imageUrl: RecipeImgUrls.nkatie_Cake,
        collection: false,
        favorite: false,
        mealType: MealType.snack,
        videoLink: RecipeVideoUrls.nkatie_Cake),
    Recipe(
        id: 11,
        name: "Adaakwa (Zowey)",
        mins: 15,
        numIngredients: 5,
        direction: RecipeDirections.adaakwaDir,
        ingredients: RecipeIngredients.adaakwaIngr,
        imageUrl: RecipeImgUrls.adaakwa,
        collection: false,
        favorite: false,
        mealType: MealType.snack,
        videoLink: RecipeVideoUrls.adaakwa),
    Recipe(
        id: 12,
        name: "Fante Fante",
        mins: 52,
        numIngredients: 11,
        direction: RecipeDirections.fanteFanteDir,
        ingredients: RecipeIngredients.fanteFanteIngr,
        imageUrl: RecipeImgUrls.fante_fante,
        collection: false,
        favorite: false,
        mealType: MealType.dinner,
        videoLink: RecipeVideoUrls.fante_fante),
    Recipe(
        id: 13,
        name: "Ga Kenkey",
        mins: 145,
        numIngredients: 5,
        direction: RecipeDirections.gaKenkeyDir,
        ingredients: RecipeIngredients.gaKenkeyIngr,
        imageUrl: RecipeImgUrls.ga_kenkey,
        collection: false,
        favorite: false,
        mealType: MealType.dinner,
        videoLink: RecipeVideoUrls.ga_kenkey),
    Recipe(
        id: 14,
        name: "Fried Rice",
        mins: 43,
        numIngredients: 12,
        direction: RecipeDirections.friedRiceDir,
        ingredients: RecipeIngredients.friedRiceIngr,
        imageUrl: RecipeImgUrls.fried_Rice,
        collection: true,
        favorite: false,
        mealType: MealType.lunch,
        videoLink: RecipeVideoUrls.fried_Rice),
    Recipe(
        id: 15,
        name: "Jollof Rice",
        mins: 70,
        numIngredients: 13,
        direction: RecipeDirections.jollofRiceDir,
        ingredients: RecipeIngredients.jollofRiceIngr,
        imageUrl: RecipeImgUrls.jollof_Rice,
        collection: true,
        favorite: false,
        mealType: MealType.lunch,
        videoLink: RecipeVideoUrls.jollof_Rice),
    Recipe(
        id: 16,
        name: "Waakye",
        mins: 72,
        numIngredients: 4,
        direction: RecipeDirections.waakyeDir,
        ingredients: RecipeIngredients.waakyeIngr,
        imageUrl: RecipeImgUrls.waakye,
        collection: false,
        favorite: false,
        mealType: MealType.lunch,
        videoLink: RecipeVideoUrls.waakye),
    Recipe(
        id: 17,
        name: "Rice Water",
        mins: 30,
        numIngredients: 6,
        direction: RecipeDirections.riceWaterDir,
        ingredients: RecipeIngredients.riceWaterIngr,
        imageUrl: RecipeImgUrls.rice_water,
        collection: true,
        favorite: true,
        mealType: MealType.breakfast,
        videoLink: RecipeVideoUrls.rice_water),
    Recipe(
        id: 18,
        name: "Tatale",
        mins: 60,
        numIngredients: 8,
        direction: RecipeDirections.tataleDir,
        ingredients: RecipeIngredients.tataleIngr,
        imageUrl: RecipeImgUrls.tatale,
        collection: false,
        favorite: false,
        mealType: MealType.snack,
        videoLink: RecipeVideoUrls.tatale),
    Recipe(
        id: 19,
        name: "Nkate Nkwan",
        mins: 50,
        numIngredients: 12,
        direction: RecipeDirections.nkateNkwanDir,
        ingredients: RecipeIngredients.nkateNkwanIngr,
        imageUrl: RecipeImgUrls.nkate_nkwan,
        collection: true,
        favorite: false,
        mealType: MealType.dinner,
        videoLink: RecipeVideoUrls.nkate_nkwan),
    Recipe(
        id: 20,
        name: "Banku",
        mins: 30,
        numIngredients: 3,
        direction: RecipeDirections.bankuDir,
        ingredients: RecipeIngredients.bankuIngr,
        imageUrl: RecipeImgUrls.banku,
        collection: true,
        favorite: true,
        mealType: MealType.dinner,
        videoLink: RecipeVideoUrls.banku),
    Recipe(
        id: 21,
        name: "Mputomputo",
        mins: 40,
        numIngredients: 11,
        direction: RecipeDirections.mputomputoDir,
        ingredients: RecipeIngredients.mputomputoIngr,
        imageUrl: RecipeImgUrls.mputomputo,
        collection: true,
        favorite: false,
        mealType: MealType.lunch,
        videoLink: RecipeVideoUrls.mputomputo),
    Recipe(
        id: 22,
        name: "Kontomire Stew",
        mins: 45,
        numIngredients: 11,
        direction: RecipeDirections.kontomireStewDir,
        ingredients: RecipeIngredients.kontomireStewIngr,
        imageUrl: RecipeImgUrls.kontomire_stew,
        collection: true,
        favorite: true,
        mealType: MealType.dinner,
        videoLink: RecipeVideoUrls.kontomire_stew)
  ];

  static List<Day> days = [
  Day(id: DayIds.sunday, name: "Sunday", breakfast: 3, lunch: 14, dinner: 22),
  Day(id: DayIds.monday, name: "Monday", breakfast: 0, lunch: 1, dinner: 2),
  Day(id: DayIds.tuesday, name: "Tuesday", breakfast: 0, lunch: 1, dinner: 2),
  Day(id: DayIds.wednesday, name: "Wednesday", breakfast: 17, lunch: 1, dinner: 20),
  Day(id: DayIds.thursday, name: "Thursday", breakfast: 0, lunch: 21, dinner: 2),
  Day(id: DayIds.friday, name: "Friday", breakfast: 3, lunch: 14, dinner: 22),
  Day(id: DayIds.saturday, name: "Saturday", breakfast: 0, lunch: 1, dinner: 2),
];
}
