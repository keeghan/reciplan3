import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reciplan3/logic/core/models/day_plan.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/planned_meal.dart';
import 'package:reciplan3/logic/core/models/week_plan.dart';
import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
import 'package:reciplan3/logic/data/services/preferences_service.dart';
import 'package:reciplan3/logic/grocery/grocery_list_cubit.dart';
import 'package:reciplan3/logic/plan/meal_plan_cubit.dart';
import 'package:reciplan3/logic/plan/meal_plan_state.dart';

import '../../support/test_fakes.dart';

void main() {
  group('MealPlanCubit', () {
    late FakeDayDao dayDao;
    late MealPlanCubit cubit;

    setUp(() {
      dayDao = FakeDayDao();
      cubit = MealPlanCubit(MealPlanRepository(dayDao));
    });

    tearDown(() async {
      await cubit.close();
      await dayDao.dispose();
    });

    test('watchPlan emits loading then loaded state', () async {
      final emittedStates = <MealPlanState>[];
      final subscription = cubit.stream.listen(emittedStates.add);

      cubit.watchPlan();
      dayDao.emitDay(1, breakfast: 10, lunch: 1, dinner: 2);
      dayDao.emitDayRecipes(1, [
        buildRecipe(id: 10, name: 'Breakfast', mealType: MealType.breakfast),
      ]);
      for (var dayId = 2; dayId <= 7; dayId++) {
        dayDao.emitDay(dayId);
        dayDao.emitDayRecipes(dayId, const []);
      }
      await Future<void>.delayed(Duration.zero);

      expect(emittedStates, isNotEmpty);
      expect(emittedStates.first.isLoading, isTrue);
      expect(emittedStates.last.isLoading, isFalse);
      expect(emittedStates.last.weekPlan, isNotNull);
      expect(emittedStates.last.weekPlan!.days.first.meals.first.recipe.name,
          'Breakfast');

      await subscription.cancel();
    });

    test('clearWeekPlan emits an action message', () async {
      final emittedStates = <MealPlanState>[];
      final subscription = cubit.stream.listen(emittedStates.add);

      await cubit.clearWeekPlan();
      await Future<void>.delayed(Duration.zero);

      expect(dayDao.clearPlansCalled, isTrue);
      expect(emittedStates, isNotEmpty);
      expect(emittedStates.last.actionMessage, 'Plans cleared');

      await subscription.cancel();
    });
  });

  group('GroceryListCubit', () {
    late PreferencesService preferencesService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferencesService =
          PreferencesService(await SharedPreferences.getInstance());
    });

    test('groups ingredients by recipe and excludes empty and unset meals',
        () async {
      final recipe = buildRecipe(id: 10, name: 'Jollof')
          .copyWith(ingredients: ' Rice \n\nTomatoes ');
      final plan = WeekPlan(days: [
        DayPlan(
          dayId: 1,
          dayName: 'Sunday',
          meals: [
            PlannedMeal(slot: MealSlot.breakfast, recipe: recipe),
            PlannedMeal(
              slot: MealSlot.lunch,
              recipe: buildRecipe(id: 1, mealType: MealType.missing),
            ),
          ],
        ),
        DayPlan(
          dayId: 2,
          dayName: 'Monday',
          meals: [PlannedMeal(slot: MealSlot.dinner, recipe: recipe)],
        ),
      ]);
      final cubit = GroceryListCubit(preferencesService, plan);

      await cubit.load();

      expect(cubit.state.groups, hasLength(1));
      expect(cubit.state.groups.single.recipeName, 'Jollof');
      expect(cubit.state.groups.single.plannedCount, 2);
      expect(
        cubit.state.groups.single.items.map((item) => item.label),
        ['Rice', 'Tomatoes'],
      );
      await cubit.close();
    });

    test('restores checks for the same plan and resets them for a changed plan',
        () async {
      final recipe =
          buildRecipe(id: 10).copyWith(ingredients: 'Rice\nTomatoes');
      final plan = WeekPlan(days: [
        DayPlan(
          dayId: 1,
          dayName: 'Sunday',
          meals: [PlannedMeal(slot: MealSlot.breakfast, recipe: recipe)],
        ),
      ]);
      final firstCubit = GroceryListCubit(preferencesService, plan);
      await firstCubit.load();
      await firstCubit.toggleItem('10:0');
      await firstCubit.close();

      final restoredCubit = GroceryListCubit(preferencesService, plan);
      await restoredCubit.load();
      expect(restoredCubit.state.checkedItemKeys, {'10:0'});
      await restoredCubit.close();

      final changedRecipe = recipe.copyWith(ingredients: 'Rice\nOnions');
      final changedPlan = WeekPlan(days: [
        DayPlan(
          dayId: 1,
          dayName: 'Sunday',
          meals: [PlannedMeal(slot: MealSlot.breakfast, recipe: changedRecipe)],
        ),
      ]);
      final changedCubit = GroceryListCubit(preferencesService, changedPlan);
      await changedCubit.load();
      expect(changedCubit.state.checkedItemKeys, isEmpty);
      await changedCubit.close();
    });

    test('reset clears checked items', () async {
      final recipe = buildRecipe(id: 10).copyWith(ingredients: 'Rice');
      final plan = WeekPlan(days: [
        DayPlan(
          dayId: 1,
          dayName: 'Sunday',
          meals: [PlannedMeal(slot: MealSlot.breakfast, recipe: recipe)],
        ),
      ]);
      final cubit = GroceryListCubit(preferencesService, plan);
      await cubit.load();
      await cubit.toggleItem('10:0');

      await cubit.resetCheckedItems();

      expect(cubit.state.checkedItemKeys, isEmpty);
      expect(preferencesService.groceryCheckedItemKeys, isEmpty);
      await cubit.close();
    });
  });
}
