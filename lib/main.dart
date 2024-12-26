import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:reciplan3/data/daos/recipe_dao.dart';
import 'package:reciplan3/data/db/database_provider.dart';
import 'package:reciplan3/data/db/reciplan_database.dart';
import 'package:reciplan3/data/repositories/day_repository.dart';

import 'data/daos/day_dao.dart';
import 'data/repositories/recipe_repository.dart';
import 'plan_viewmodel.dart';
import 'recipe_viewmodel.dart';
import 'ui/my_home_page.dart';
import 'util/theme_provider.dart';

//Inject Singleton database,DAOs,Repositories and ViewModels
final locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerSingletonAsync<ReciplanDatabase>(() => DatabaseProvider.database);
  locator.registerSingletonAsync<RecipeDao>(() => DatabaseProvider.recipeDao);
  locator.registerSingletonAsync<DayDao>(() => DatabaseProvider.dayDao);

  await locator.allReady();
  locator.registerSingleton<RecipeRepository>(RecipeRepository(locator<RecipeDao>()));
  locator.registerSingleton<DayRepository>(DayRepository(locator<DayDao>()));

  locator.registerFactory<RecipeViewModel>(() => RecipeViewModel(locator<RecipeRepository>()));
  locator.registerFactory<PlanViewModel>(() =>PlanViewModel(locator<RecipeRepository>(), locator<DayRepository>()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Reciplan 3',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MyHomePage(title: 'Reciplan 3'),
        );
      },
    );
  }
}

//Themes for easy Access
final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 9, 117, 12),
    secondary: const Color.fromARGB(222, 201, 128, 4),
  ),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 9, 117, 12),
    secondary: const Color.fromARGB(222, 201, 128, 4),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
