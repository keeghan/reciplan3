import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/week_plan.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'package:reciplan3/logic/data/services/preferences_service.dart';
import 'grocery_list_state.dart';

class GroceryListCubit extends Cubit<GroceryListState> {
  final PreferencesService _preferencesService;
  final WeekPlan _weekPlan;
  late final String _planSignature;

  GroceryListCubit(this._preferencesService, this._weekPlan)
      : super(const GroceryListState());

  // Loads grocery groups and saved progress.
  Future<void> load() async {
    final groups = _buildGroups();
    _planSignature = _buildPlanSignature();

    try {
      final signatureMatches =
          _preferencesService.groceryPlanSignature == _planSignature;
      final checkedKeys = signatureMatches
          ? _preferencesService.groceryCheckedItemKeys
          : <String>{};
      final validKeys =
          groups.expand((group) => group.items).map((item) => item.key).toSet();
      final restoredKeys = checkedKeys.intersection(validKeys);

      if (!signatureMatches) {
        await _preferencesService.setGroceryCheckedItemKeys({});
        await _preferencesService.setGroceryPlanSignature(_planSignature);
      } else if (restoredKeys.length != checkedKeys.length) {
        await _preferencesService.setGroceryCheckedItemKeys(restoredKeys);
      }

      emit(GroceryListState(
        isLoading: false,
        groups: groups,
        checkedItemKeys: restoredKeys,
      ));
    } catch (_) {
      emit(GroceryListState(
        isLoading: false,
        groups: groups,
        errorMessage: 'Could not load saved grocery progress',
      ));
    }
  }

  // Toggles one grocery item.
  Future<void> toggleItem(String itemKey) async {
    final checkedKeys = Set<String>.from(state.checkedItemKeys);
    if (!checkedKeys.add(itemKey)) {
      checkedKeys.remove(itemKey);
    }
    emit(state.copyWith(checkedItemKeys: checkedKeys, clearError: true));
    await _saveProgress(checkedKeys);
  }

  // Clears all grocery checkmarks.
  Future<void> resetCheckedItems() async {
    emit(state.copyWith(checkedItemKeys: <String>{}, clearError: true));
    await _saveProgress(<String>{});
  }

  // Clears the current error.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  // Persists visible grocery progress.
  Future<void> _saveProgress(Set<String> checkedKeys) async {
    try {
      await _preferencesService.setGroceryCheckedItemKeys(checkedKeys);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not save grocery progress'));
    }
  }

  // Builds recipe groups in plan order.
  List<GroceryGroup> _buildGroups() {
    final recipes = <String, Recipe>{};
    final counts = <String, int>{};

    for (final day in _weekPlan.days) {
      for (final meal in day.meals) {
        final recipe = meal.recipe;
        if (recipe.mealTypeEnum == MealType.missing) {
          continue;
        }
        final recipeKey = _recipeKey(recipe);
        recipes.putIfAbsent(recipeKey, () => recipe);
        counts[recipeKey] = (counts[recipeKey] ?? 0) + 1;
      }
    }

    return recipes.entries
        .map((entry) {
          final recipeKey = entry.key;
          final recipe = entry.value;
          final lines = recipe.ingredients.split(RegExp(r'\r?\n'));
          final items = <GroceryItem>[];
          for (var index = 0; index < lines.length; index++) {
            final label = lines[index].trim();
            if (label.isNotEmpty) {
              items.add(GroceryItem(key: '$recipeKey:$index', label: label));
            }
          }
          return GroceryGroup(
            recipeName: recipe.name,
            plannedCount: counts[recipeKey]!,
            items: items,
          );
        })
        .where((group) => group.items.isNotEmpty)
        .toList();
  }

  // Builds a deterministic signature for the plan.
  String _buildPlanSignature() {
    return jsonEncode([
      for (final day in _weekPlan.days)
        for (final meal in day.meals)
          {
            'day': day.dayId,
            'slot': meal.slot.name,
            'recipe': meal.recipe.id,
            'ingredients': meal.recipe.ingredients,
          },
    ]);
  }

  // Returns a stable recipe key.
  String _recipeKey(Recipe recipe) {
    return recipe.id?.toString() ?? 'name:${recipe.name}';
  }
}
