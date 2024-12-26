import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:reciplan3/data/daos/recipe_dao.dart';
import 'package:reciplan3/data/db/database_provider.dart';
import 'package:reciplan3/data/db/reciplan_database.dart';

import 'data/daos/day_dao.dart';
import 'data/repositories/recipe_repository.dart';
import 'recipe_viewmodel.dart';
import 'ui/my_home_page.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerSingletonAsync<ReciplanDatabase>(
      () => DatabaseProvider.database);
  locator.registerSingletonAsync<RecipeDao>(() => DatabaseProvider.recipeDao);
  locator.registerSingletonAsync<DayDao>(() => DatabaseProvider.dayDao);
  await locator.allReady();
  locator.registerSingleton<RecipeRepository>(
      RecipeRepository(locator<RecipeDao>()));
  locator.registerFactory<RecipeViewModel>(
      () => RecipeViewModel(locator<RecipeRepository>()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 9, 117, 12),
          secondary: const Color.fromARGB(222, 201, 128, 4),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
