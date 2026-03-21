import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:reciplan3/logic/data/daos/day_dao.dart';
import 'package:reciplan3/logic/data/daos/recipe_dao.dart';
import 'package:reciplan3/logic/data/entities/day.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';

part 'reciplan_database.g.dart';

@Database(version: 1, entities: [Recipe, Day])
abstract class ReciplanDatabase extends FloorDatabase {
  RecipeDao get recipeDao;
  DayDao get dayDao;
}
