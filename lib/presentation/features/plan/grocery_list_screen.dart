import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/core/models/week_plan.dart';
import 'package:reciplan3/logic/data/services/preferences_service.dart';
import 'package:reciplan3/logic/grocery/grocery_list_cubit.dart';
import 'package:reciplan3/logic/grocery/grocery_list_state.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';
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

  // Uses one phone list or constrained tablet group columns.
  @override
  Widget build(BuildContext context) {
    return BlocListener<GroceryListCubit, GroceryListState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage && current.errorMessage != null,
      listener: (context, state) {
        MyUtils.showSnackBar(context, state.errorMessage!);
        context.read<GroceryListCubit>().clearError();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grocery list'),
          actions: [
            BlocBuilder<GroceryListCubit, GroceryListState>(
              buildWhen: (previous, current) => previous.hasCheckedItems != current.hasCheckedItems,
              builder: (context, state) {
                return IconButton(
                  tooltip: 'Reset checkmarks',
                  onPressed: state.hasCheckedItems
                      ? () => context.read<GroceryListCubit>().resetCheckedItems()
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
            final windowClass = AppBreakpoints.windowClass(context);
            if (windowClass != AppWindowClass.compact) {
              final columns = windowClass == AppWindowClass.expanded ? 2 : 1;
              return SingleChildScrollView(
                child: AppConstrainedContent(
                  maxWidth: columns == 2
                      ? AppBreakpoints.standardContent
                      : AppBreakpoints.readableContent,
                  padding: EdgeInsets.fromLTRB(
                    AppBreakpoints.gutter(context),
                    8,
                    AppBreakpoints.gutter(context),
                    32,
                  ),
                  child: Column(
                    children: [
                      _GroceryProgress(state: state),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = 16.0;
                          final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
                          return Wrap(
                            spacing: spacing,
                            children: [
                              for (var index = 0; index < state.groups.length; index++)
                                SizedBox(
                                  width: width,
                                  child: AppEntrance(
                                    index: index,
                                    child: _GroceryGroupCard(
                                      group: state.groups[index],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: state.groups.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _GroceryProgress(state: state);
                }
                return AppEntrance(
                  index: index - 1,
                  child: _GroceryGroupCard(group: state.groups[index - 1]),
                );
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
    return const AppEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Your grocery list is empty',
      message: 'Add meals with ingredients to your weekly plan.',
    );
  }
}

class _GroceryProgress extends StatelessWidget {
  final GroceryListState state;

  const _GroceryProgress({required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.groups.fold<int>(
      0,
      (count, group) => count + group.items.length,
    );
    final checked = state.checkedItemKeys.length;
    final progress = total == 0 ? 0.0 : checked / total;
    return AppEntrance(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      checked == total ? 'All checked off' : 'Shopping progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text('$checked of $total'),
                ],
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: AppMotion.duration(context, AppMotion.state),
                curve: AppMotion.stateCurve,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
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
                  Chip(
                    label: Text('${group.plannedCount} meals'),
                    backgroundColor: colorScheme.secondaryContainer,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
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
                  title: AnimatedDefaultTextStyle(
                    duration: AppMotion.duration(context, AppMotion.state),
                    curve: AppMotion.stateCurve,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked ? colorScheme.onSurfaceVariant : null,
                        ),
                    child: Text(item.label),
                  ),
                  onChanged: (_) {
                    if (context.read<AppSettingsCubit>().state.hapticsEnabled) {
                      HapticFeedback.selectionClick();
                    }
                    context.read<GroceryListCubit>().toggleItem(item.key);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
