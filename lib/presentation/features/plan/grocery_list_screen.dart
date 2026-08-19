import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/core/models/week_plan.dart';
import 'package:reciplan3/logic/data/services/preferences_service.dart';
import 'package:reciplan3/logic/grocery/grocery_list_cubit.dart';
import 'package:reciplan3/logic/grocery/grocery_list_state.dart';
import 'package:reciplan3/util/utils.dart';

class GroceryListScreen extends StatelessWidget {
  final WeekPlan weekPlan;

  const GroceryListScreen({
    super.key,
    required this.weekPlan,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroceryListCubit(
        context.read<PreferencesService>(),
        weekPlan,
      )..load(),
      child: const _GroceryListView(),
    );
  }
}

class _GroceryListView extends StatelessWidget {
  const _GroceryListView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroceryListCubit, GroceryListState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        MyUtils.showSnackBar(context, state.errorMessage!);
        context.read<GroceryListCubit>().clearError();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ReciplanCustomColors.appBarColor,
          foregroundColor: Colors.white,
          title: const Text('Grocery List'),
          actions: [
            BlocBuilder<GroceryListCubit, GroceryListState>(
              buildWhen: (previous, current) =>
                  previous.hasCheckedItems != current.hasCheckedItems,
              builder: (context, state) {
                return IconButton(
                  tooltip: 'Reset checkmarks',
                  onPressed: state.hasCheckedItems
                      ? () =>
                          context.read<GroceryListCubit>().resetCheckedItems()
                      : null,
                  icon: const Icon(Icons.restart_alt),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<GroceryListCubit, GroceryListState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.isEmpty) {
              return const _EmptyGroceryList();
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                return _GroceryGroupCard(group: state.groups[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyGroceryList extends StatelessWidget {
  const _EmptyGroceryList();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 56),
            SizedBox(height: 16),
            Text(
              'Your grocery list is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Add meals with ingredients to your weekly plan.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroceryGroupCard extends StatelessWidget {
  final GroceryGroup group;

  const _GroceryGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.recipeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (group.plannedCount > 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Planned ${group.plannedCount} times'),
                  ),
              ],
            ),
          ),
          for (final item in group.items)
            BlocSelector<GroceryListCubit, GroceryListState, bool>(
              selector: (state) => state.checkedItemKeys.contains(item.key),
              builder: (context, isChecked) {
                return CheckboxListTile(
                  value: isChecked,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    item.label,
                    style: TextStyle(
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                  onChanged: (_) =>
                      context.read<GroceryListCubit>().toggleItem(item.key),
                );
              },
            ),
        ],
      ),
    );
  }
}
