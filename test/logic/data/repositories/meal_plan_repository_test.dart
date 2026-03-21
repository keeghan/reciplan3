import 'package:flutter_test/flutter_test.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/week_plan.dart';
import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';

import '../../../support/test_fakes.dart';

void main() {
  group('MealPlanRepository', () {
    late FakeDayDao dayDao;
    late MealPlanRepository repository;

    setUp(() {
      dayDao = FakeDayDao();
      repository = MealPlanRepository(dayDao);
    });

    tearDown(() async {
      await dayDao.dispose();
    });

    test('watchWeekPlan maps seven days and pads missing meals with placeholders', () async {
      final weekPlanFuture = repository.watchWeekPlan().first;

      dayDao.emitDay(1, breakfast: 10, lunch: 1, dinner: 2);
      dayDao.emitDayRecipes(1, [
        buildRecipe(id: 10, name: 'Wakye', mealType: MealType.breakfast),
      ]);
      for (var dayId = 2; dayId <= 7; dayId++) {
        dayDao.emitDay(dayId);
        dayDao.emitDayRecipes(dayId, const []);
      }

      final weekPlan = await weekPlanFuture;

      expect(weekPlan.days, hasLength(7));
      expect(weekPlan.days.first.dayName, 'Sunday');
      expect(weekPlan.days.first.meals, hasLength(3));
      expect(weekPlan.days.first.meals[0].slot, MealSlot.breakfast);
      expect(weekPlan.days.first.meals[0].recipe.name, 'Wakye');
      expect(weekPlan.days.first.meals[1].recipe.name, 'Lunch not Set');
      expect(weekPlan.days.first.meals[2].recipe.name, 'Dinner not Set');
      expect(weekPlan.days[1].meals[0].recipe.name, 'Breakfast not Set');
    });

    test('assignRecipe routes updates to the matching slot query', () async {
      await repository.assignRecipe(
        dayId: 2,
        slot: MealSlot.breakfast,
        recipeId: 10,
      );
      await repository.assignRecipe(
        dayId: 3,
        slot: MealSlot.lunch,
        recipeId: 11,
      );
      await repository.assignRecipe(
        dayId: 4,
        slot: MealSlot.dinner,
        recipeId: 12,
      );

      expect(dayDao.updatedBreakfastDayId, 2);
      expect(dayDao.updatedBreakfastRecipeId, 10);
      expect(dayDao.updatedLunchDayId, 3);
      expect(dayDao.updatedLunchRecipeId, 11);
      expect(dayDao.updatedDinnerDayId, 4);
      expect(dayDao.updatedDinnerRecipeId, 12);
    });

    test('clearWeekPlan delegates to the dao', () async {
      await repository.clearWeekPlan();
      expect(dayDao.clearPlansCalled, isTrue);
    });

    test('watchWeekPlan emits updated data when the day assignment changes', () async {
      final emittedPlans = <WeekPlan>[];
      final subscription = repository.watchWeekPlan().listen(emittedPlans.add);

      dayDao.emitDay(1, breakfast: 10, lunch: 1, dinner: 2);
      dayDao.emitDayRecipes(1, [
        buildRecipe(id: 10, name: 'Wakye', mealType: MealType.breakfast),
      ]);
      for (var dayId = 2; dayId <= 7; dayId++) {
        dayDao.emitDay(dayId);
        dayDao.emitDayRecipes(dayId, const []);
      }
      await Future<void>.delayed(Duration.zero);

      dayDao.emitDay(1, breakfast: 20, lunch: 1, dinner: 2);
      dayDao.emitDayRecipes(1, [
        buildRecipe(id: 20, name: 'Hausa Kooko', mealType: MealType.breakfast),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(emittedPlans.length, greaterThanOrEqualTo(2));
      expect(emittedPlans.first.days.first.meals.first.recipe.name, 'Wakye');
      expect(emittedPlans.last.days.first.meals.first.recipe.name, 'Hausa Kooko');

      await subscription.cancel();
    });
  });
}
