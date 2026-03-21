import 'package:flutter_test/flutter_test.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
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
      expect(emittedStates.last.weekPlan!.days.first.meals.first.recipe.name, 'Breakfast');

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
}
