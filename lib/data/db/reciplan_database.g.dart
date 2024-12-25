// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reciplan_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $ReciplanDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $ReciplanDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $ReciplanDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<ReciplanDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorReciplanDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $ReciplanDatabaseBuilderContract databaseBuilder(String name) =>
      _$ReciplanDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $ReciplanDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$ReciplanDatabaseBuilder(null);
}

class _$ReciplanDatabaseBuilder implements $ReciplanDatabaseBuilderContract {
  _$ReciplanDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $ReciplanDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $ReciplanDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<ReciplanDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$ReciplanDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$ReciplanDatabase extends ReciplanDatabase {
  _$ReciplanDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RecipeDao? _recipeDaoInstance;

  DayDao? _dayDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `recipe_table` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `mins` INTEGER NOT NULL, `numIngredients` INTEGER NOT NULL, `direction` TEXT NOT NULL, `ingredients` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `collection` INTEGER NOT NULL, `favorite` INTEGER NOT NULL, `mealType` INTEGER NOT NULL, `userCreated` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `day_table` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `breakfast` INTEGER NOT NULL, `lunch` INTEGER NOT NULL, `dinner` INTEGER NOT NULL, FOREIGN KEY (`breakfast`) REFERENCES `recipe_table` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`lunch`) REFERENCES `recipe_table` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`dinner`) REFERENCES `recipe_table` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE INDEX `index_day_table_breakfast` ON `day_table` (`breakfast`)');
        await database.execute(
            'CREATE INDEX `index_day_table_lunch` ON `day_table` (`lunch`)');
        await database.execute(
            'CREATE INDEX `index_day_table_dinner` ON `day_table` (`dinner`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  RecipeDao get recipeDao {
    return _recipeDaoInstance ??= _$RecipeDao(database, changeListener);
  }

  @override
  DayDao get dayDao {
    return _dayDaoInstance ??= _$DayDao(database, changeListener);
  }
}

class _$RecipeDao extends RecipeDao {
  _$RecipeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _recipeInsertionAdapter = InsertionAdapter(
            database,
            'recipe_table',
            (Recipe item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'mins': item.mins,
                  'numIngredients': item.numIngredients,
                  'direction': item.direction,
                  'ingredients': item.ingredients,
                  'imageUrl': item.imageUrl,
                  'collection': item.collection ? 1 : 0,
                  'favorite': item.favorite ? 1 : 0,
                  'mealType': item.mealType,
                  'userCreated': item.userCreated ? 1 : 0
                },
            changeListener),
        _recipeUpdateAdapter = UpdateAdapter(
            database,
            'recipe_table',
            ['id'],
            (Recipe item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'mins': item.mins,
                  'numIngredients': item.numIngredients,
                  'direction': item.direction,
                  'ingredients': item.ingredients,
                  'imageUrl': item.imageUrl,
                  'collection': item.collection ? 1 : 0,
                  'favorite': item.favorite ? 1 : 0,
                  'mealType': item.mealType,
                  'userCreated': item.userCreated ? 1 : 0
                },
            changeListener),
        _recipeDeletionAdapter = DeletionAdapter(
            database,
            'recipe_table',
            ['id'],
            (Recipe item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'mins': item.mins,
                  'numIngredients': item.numIngredients,
                  'direction': item.direction,
                  'ingredients': item.ingredients,
                  'imageUrl': item.imageUrl,
                  'collection': item.collection ? 1 : 0,
                  'favorite': item.favorite ? 1 : 0,
                  'mealType': item.mealType,
                  'userCreated': item.userCreated ? 1 : 0
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Recipe> _recipeInsertionAdapter;

  final UpdateAdapter<Recipe> _recipeUpdateAdapter;

  final DeletionAdapter<Recipe> _recipeDeletionAdapter;

  @override
  Future<void> deleteRecipeById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM recipe_table WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> clearRecipeFromBreakfast(int recipeId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE day_table SET breakfast = 0 WHERE breakfast = ?1',
        arguments: [recipeId]);
  }

  @override
  Future<void> clearRecipeFromLunch(int recipeId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE day_table SET lunch = 1 WHERE lunch = ?1',
        arguments: [recipeId]);
  }

  @override
  Future<void> clearRecipeFromDinner(int recipeId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE day_table SET dinner = 2 WHERE dinner = ?1',
        arguments: [recipeId]);
  }

  @override
  Future<Recipe?> getRecipe(int recipeId) async {
    return _queryAdapter.query('SELECT * FROM recipe_table WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        arguments: [recipeId]);
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    return _queryAdapter.queryList(
        'SELECT * FROM recipe_table ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0));
  }

  @override
  Stream<List<Recipe>> getCollectionsRecipes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table WHERE collection = 1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Stream<List<Recipe>> getFavoriteRecipes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table WHERE favorite = 1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Stream<List<Recipe>> getSnackRecipes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table WHERE type = \'snack\' ORDER BY id',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Stream<List<Recipe>> getBreakfastRecipes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table WHERE type = \'breakfast\' ORDER BY id',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Stream<List<Recipe>> getDinnerRecipes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table WHERE type = \'dinner\'',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Stream<List<Recipe>> getLunchRecipes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table WHERE type = \'lunch\'',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Future<void> clearCollection() async {
    await _queryAdapter
        .queryNoReturn('UPDATE recipe_table SET collection = 0, favorite = 0');
  }

  @override
  Future<void> clearFavorite() async {
    await _queryAdapter.queryNoReturn('UPDATE recipe_table SET favorite = 0');
  }

  @override
  Future<void> clearPlans() async {
    await _queryAdapter.queryNoReturn(
        'UPDATE day_table SET breakfast = 0, lunch = 1, dinner = 2');
  }

  @override
  Stream<List<Recipe>> getBreakfastCollectionRecipes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table WHERE mealType = 0 AND collection = 1',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Stream<List<Recipe>> getDinnerCollectionRecipes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table WHERE mealType = 2 AND collection = 1',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Stream<List<Recipe>> getLunchCollectionRecipes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table WHERE mealType = 1 AND collection = 1',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Stream<List<Recipe>> getSnackCollectionRecipes() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table WHERE mealType = 3 AND collection = 1',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Future<List<Recipe>> getActiveDayRecipes(List<int> dayIDs) async {
    const offset = 1;
    final _sqliteVariablesForDayIDs =
        Iterable<String>.generate(dayIDs.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM recipe_table WHERE id IN (' +
            _sqliteVariablesForDayIDs +
            ')',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        arguments: [...dayIDs]);
  }

  @override
  Stream<List<Recipe>> getThreeRecipesInOrder(
    int firstId,
    int secondId,
    int thirdId,
  ) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM recipe_table      WHERE id = ?1 OR id = ?2 OR id = ?3     ORDER BY CASE id        WHEN ?1 THEN 1        WHEN ?2 THEN 2        WHEN ?3 THEN 3      END',
        mapper: (Map<String, Object?> row) => Recipe(
            id: row['id'] as int,
            name: row['name'] as String,
            mins: row['mins'] as int,
            numIngredients: row['numIngredients'] as int,
            direction: row['direction'] as String,
            ingredients: row['ingredients'] as String,
            imageUrl: row['imageUrl'] as String,
            collection: (row['collection'] as int) != 0,
            favorite: (row['favorite'] as int) != 0,
            mealType: row['mealType'] as int,
            userCreated: (row['userCreated'] as int) != 0),
        arguments: [firstId, secondId, thirdId],
        queryableName: 'recipe_table',
        isView: false);
  }

  @override
  Future<void> insertRecipe(Recipe recipe) async {
    await _recipeInsertionAdapter.insert(recipe, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertRecipes(List<Recipe> recipes) async {
    await _recipeInsertionAdapter.insertList(
        recipes, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    await _recipeUpdateAdapter.update(recipe, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRecipe(Recipe recipe) async {
    await _recipeDeletionAdapter.delete(recipe);
  }

  @override
  Future<void> deleteRecipeWithClear(Recipe recipe) async {
    if (database is sqflite.Transaction) {
      await super.deleteRecipeWithClear(recipe);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$ReciplanDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.recipeDao.deleteRecipeWithClear(recipe);
      });
    }
  }
}

class _$DayDao extends DayDao {
  _$DayDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _dayInsertionAdapter = InsertionAdapter(
            database,
            'day_table',
            (Day item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'breakfast': item.breakfast,
                  'lunch': item.lunch,
                  'dinner': item.dinner
                }),
        _recipeInsertionAdapter = InsertionAdapter(
            database,
            'recipe_table',
            (Recipe item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'mins': item.mins,
                  'numIngredients': item.numIngredients,
                  'direction': item.direction,
                  'ingredients': item.ingredients,
                  'imageUrl': item.imageUrl,
                  'collection': item.collection ? 1 : 0,
                  'favorite': item.favorite ? 1 : 0,
                  'mealType': item.mealType,
                  'userCreated': item.userCreated ? 1 : 0
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Day> _dayInsertionAdapter;

  final InsertionAdapter<Recipe> _recipeInsertionAdapter;

  @override
  Future<Day?> getDay(int dayId) async {
    return _queryAdapter.query('SELECT * FROM day_table WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Day(
            id: row['id'] as int,
            name: row['name'] as String,
            breakfast: row['breakfast'] as int,
            lunch: row['lunch'] as int,
            dinner: row['dinner'] as int),
        arguments: [dayId]);
  }

  @override
  Future<List<Day>> getAllDays() async {
    return _queryAdapter.queryList('SELECT * FROM day_table',
        mapper: (Map<String, Object?> row) => Day(
            id: row['id'] as int,
            name: row['name'] as String,
            breakfast: row['breakfast'] as int,
            lunch: row['lunch'] as int,
            dinner: row['dinner'] as int));
  }

  @override
  Future<void> updateBreakfast(
    int dayId,
    int recipeId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE day_table SET breakfast = ?2 WHERE id = ?1',
        arguments: [dayId, recipeId]);
  }

  @override
  Future<void> updateLunch(
    int dayId,
    int recipeId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE day_table SET lunch = ?2 WHERE id = ?1',
        arguments: [dayId, recipeId]);
  }

  @override
  Future<void> updateDinner(
    int dayId,
    int recipeId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE day_table SET dinner = ?2 WHERE id = ?1',
        arguments: [dayId, recipeId]);
  }

  @override
  Future<void> updateSnack(
    int dayId,
    int recipeId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE day_table SET snack = ?2 WHERE id = ?1',
        arguments: [dayId, recipeId]);
  }

  @override
  Future<List<Recipe>> getRecipesForDay(int dayId) async {
    return _queryAdapter.queryList(
        'SELECT r.* FROM recipe_table r     INNER JOIN day_table d ON        r.id = d.breakfast OR        r.id = d.lunch OR        r.id = d.dinner     WHERE d.id = ?1     ORDER BY CASE r.id        WHEN d.breakfast THEN 1       WHEN d.lunch THEN 2       WHEN d.dinner THEN 3     END',
        mapper: (Map<String, Object?> row) => Recipe(id: row['id'] as int, name: row['name'] as String, mins: row['mins'] as int, numIngredients: row['numIngredients'] as int, direction: row['direction'] as String, ingredients: row['ingredients'] as String, imageUrl: row['imageUrl'] as String, collection: (row['collection'] as int) != 0, favorite: (row['favorite'] as int) != 0, mealType: row['mealType'] as int, userCreated: (row['userCreated'] as int) != 0),
        arguments: [dayId]);
  }

  @override
  Future<void> insertDay(Day day) async {
    await _dayInsertionAdapter.insert(day, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertRecipe(Recipe recipe) async {
    await _recipeInsertionAdapter.insert(recipe, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertDays(List<Day> days) async {
    await _dayInsertionAdapter.insertList(days, OnConflictStrategy.replace);
  }
}
