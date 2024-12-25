import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../daos/day_dao.dart';
import '../daos/recipe_dao.dart';
import '../entities/day.dart';
import '../entities/recipe.dart';

part 'reciplan_database.g.dart';

@Database(version: 1, entities: [Recipe, Day])
abstract class ReciplanDatabase extends FloorDatabase {
  RecipeDao get recipeDao;
  DayDao get dayDao;
}
