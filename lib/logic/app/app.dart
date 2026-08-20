import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/data/services/import_export_service.dart';
import 'package:reciplan3/logic/data/services/local_image_storage_service.dart';
import 'package:reciplan3/logic/data/services/preferences_service.dart';
import 'package:reciplan3/presentation/features/shell/home_shell.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'bootstrap/app_dependencies.dart';
import 'settings/app_settings_cubit.dart';
import 'theme/app_theme_cubit.dart';

class MyApp extends StatelessWidget {
  final AppDependencies dependencies;

  const MyApp({
    super.key,
    required this.dependencies,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RecipeRepository>.value(
            value: dependencies.recipeRepository),
        RepositoryProvider<MealPlanRepository>.value(
            value: dependencies.mealPlanRepository),
        RepositoryProvider<PreferencesService>.value(
            value: dependencies.preferencesService),
        RepositoryProvider<ImportExportService>.value(
            value: dependencies.importExportService),
        RepositoryProvider<LocalImageStorageService>.value(
          value: dependencies.localImageStorageService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AppThemeCubit(dependencies.preferencesService),
          ),
          BlocProvider(
            create: (_) => AppSettingsCubit(dependencies.preferencesService),
          ),
        ],
        child: BlocBuilder<AppThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'Reciplan 3',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeMode,
              home: const HomeShell(),
            );
          },
        ),
      ),
    );
  }
}

final ThemeData lightTheme = buildAppTheme(Brightness.light);

final ThemeData darkTheme = buildAppTheme(Brightness.dark);
