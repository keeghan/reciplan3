import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/core/models/day_plan.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/planned_meal.dart';
import 'package:reciplan3/logic/core/models/week_plan.dart';
import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/data/services/local_image_storage_service.dart';
import 'package:reciplan3/logic/data/services/preferences_service.dart';
import 'package:reciplan3/presentation/features/add/add_page.dart';
import 'package:reciplan3/presentation/features/plan/grocery_list_screen.dart';
import 'package:reciplan3/presentation/features/plan/plan_page.dart';
import 'package:reciplan3/presentation/features/recipes/collection_screen.dart';
import 'package:reciplan3/presentation/features/recipes/explore_screen.dart';
import 'package:reciplan3/presentation/features/shell/home_shell.dart';
import 'package:reciplan3/logic/app/app.dart';

import 'support/test_fakes.dart';

void main() {
  testWidgets('Explore screen shows meal categories', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ExploreScreen(),
      ),
    );

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Snack'), findsOneWidget);
  });

  testWidgets('Explore adapts to narrow, wide, dark, and reduced-motion layouts',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: darkTheme,
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: ExploreScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Breakfast'), findsOneWidget);

    tester.view.physicalSize = const Size(900, 900);
    await tester.pumpWidget(
      MaterialApp(theme: lightTheme, home: const ExploreScreen()),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Dinner'), findsOneWidget);
  });

  testWidgets('Explore has no overflow at adaptive breakpoints', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final width in [360.0, 599.0, 600.0, 839.0, 840.0, 941.0, 1280.0, 1506.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(
        MaterialApp(theme: lightTheme, home: const ExploreScreen()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Failed at $width dp');
    }
  });

  testWidgets('Home shell switches navigation without losing destination',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(599, 900);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final dayDao = FakeDayDao();
    for (var dayId = 1; dayId <= 7; dayId++) {
      dayDao.emitDay(dayId);
      dayDao.emitDayRecipes(dayId, const []);
    }
    final recipeDao = FakeRecipeDao()
      ..collectionRecipes = Stream.value(const [])
      ..favoriteRecipes = Stream.value(const []);

    await tester.pumpWidget(
      _homeShellTestApp(
        dayDao: dayDao,
        recipeDao: recipeDao,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    expect(find.text('Meal plan'), findsOneWidget);

    tester.view.physicalSize = const Size(941, 900);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Meal plan'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Create something delicious'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await dayDao.dispose();
  });

  testWidgets('Wide collection uses recipe master detail', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(941, 900);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService(await SharedPreferences.getInstance());
    final recipe = buildRecipe(id: 7, name: 'Jollof rice');
    final recipeDao = FakeRecipeDao()..collectionRecipes = Stream.value([recipe]);

    await tester.pumpWidget(
      RepositoryProvider<RecipeRepository>.value(
        value: RecipeRepository(recipeDao),
        child: BlocProvider(
          create: (_) => AppSettingsCubit(preferences),
          child: MaterialApp(
            theme: lightTheme,
            home: const CollectionScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Select a recipe'), findsOneWidget);

    await tester.tap(find.text('Jollof rice'));
    await tester.pumpAndSettle();
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Cook it'), findsOneWidget);
  });

  testWidgets('Add form uses its tablet composition', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(941, 1200);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService(await SharedPreferences.getInstance());

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<RecipeRepository>.value(
            value: RecipeRepository(FakeRecipeDao()),
          ),
          RepositoryProvider<LocalImageStorageService>.value(
            value: FakeLocalImageStorageService(),
          ),
        ],
        child: BlocProvider(
          create: (_) => AppSettingsCubit(preferences),
          child: MaterialApp(theme: lightTheme, home: const AddPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Create something delicious'), findsOneWidget);
    expect(find.text('Recipe title'), findsOneWidget);
    expect(find.text('Save recipe'), findsOneWidget);
  });

  testWidgets('Grocery list shows grouped checkable ingredients', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencesService = PreferencesService(await SharedPreferences.getInstance());
    final recipe = buildRecipe(id: 10, name: 'Jollof').copyWith(ingredients: 'Rice\nTomatoes');
    final weekPlan = WeekPlan(days: [
      DayPlan(
        dayId: 1,
        dayName: 'Sunday',
        meals: [
          PlannedMeal(slot: MealSlot.lunch, recipe: recipe),
          PlannedMeal(slot: MealSlot.dinner, recipe: recipe),
        ],
      ),
    ]);

    await tester.pumpWidget(
      RepositoryProvider<PreferencesService>.value(
        value: preferencesService,
        child: BlocProvider(
          create: (_) => AppSettingsCubit(preferencesService),
          child: MaterialApp(
            theme: lightTheme.copyWith(splashFactory: NoSplash.splashFactory),
            home: GroceryListScreen(weekPlan: weekPlan),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jollof'), findsOneWidget);
    expect(find.text('2 meals'), findsOneWidget);
    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Tomatoes'), findsOneWidget);

    await tester.tap(find.text('Rice'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedDefaultTextStyle &&
            widget.style.decoration == TextDecoration.lineThrough,
      ),
      findsOneWidget,
    );
    expect(preferencesService.groceryCheckedItemKeys, {'10:0'});
  });

  testWidgets('Grocery list shows an empty state', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencesService = PreferencesService(await SharedPreferences.getInstance());

    await tester.pumpWidget(
      RepositoryProvider<PreferencesService>.value(
        value: preferencesService,
        child: const MaterialApp(
          home: GroceryListScreen(weekPlan: WeekPlan(days: [])),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your grocery list is empty'), findsOneWidget);
    expect(
      find.text('Add meals with ingredients to your weekly plan.'),
      findsOneWidget,
    );
  });

  testWidgets('Plan grocery action opens the grocery list', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencesService = PreferencesService(await SharedPreferences.getInstance());
    final dayDao = FakeDayDao();
    for (var dayId = 1; dayId <= 7; dayId++) {
      dayDao.emitDay(dayId);
      dayDao.emitDayRecipes(dayId, const []);
    }

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<MealPlanRepository>(
            create: (_) => MealPlanRepository(dayDao),
          ),
          RepositoryProvider<PreferencesService>.value(
            value: preferencesService,
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: const PlanPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open grocery list'));
    await tester.pumpAndSettle();

    expect(find.text('Grocery list'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await dayDao.dispose();
  });
}

Widget _homeShellTestApp({
  required FakeDayDao dayDao,
  required FakeRecipeDao recipeDao,
}) {
  return FutureBuilder<SharedPreferences>(
    future: SharedPreferences.getInstance(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox.shrink();
      final preferences = PreferencesService(snapshot.data!);
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<RecipeRepository>.value(
            value: RecipeRepository(recipeDao),
          ),
          RepositoryProvider<MealPlanRepository>.value(
            value: MealPlanRepository(dayDao),
          ),
          RepositoryProvider<LocalImageStorageService>.value(
            value: FakeLocalImageStorageService(),
          ),
        ],
        child: BlocProvider(
          create: (_) => AppSettingsCubit(preferences),
          child: MaterialApp(
            theme: lightTheme,
            home: const HomeShell(),
          ),
        ),
      );
    },
  );
}
