import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/core/models/day_plan.dart';
import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
import 'package:reciplan3/presentation/widgets/plan_day_item.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/presentation/features/settings/settings_screen.dart';
import 'package:reciplan3/logic/plan/meal_plan_cubit.dart';
import 'package:reciplan3/logic/plan/meal_plan_state.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';
import 'grocery_list_screen.dart';
import 'manage_day_bottom_sheet.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MealPlanCubit(
        context.read<MealPlanRepository>(),
      )..watchPlan(),
      child: const _PlanView(),
    );
  }
}

class _PlanView extends StatelessWidget {
  const _PlanView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<MealPlanCubit, MealPlanState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.actionMessage != current.actionMessage,
      listener: (context, state) {
        final message = state.errorMessage ?? state.actionMessage;
        if (message != null) {
          MyUtils.showSnackBar(context, message);
          context.read<MealPlanCubit>().clearAction();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meal plan'),
          actions: [
            BlocBuilder<MealPlanCubit, MealPlanState>(
              buildWhen: (previous, current) => previous.weekPlan != current.weekPlan,
              builder: (context, state) {
                return IconButton(
                  tooltip: 'Open grocery list',
                  onPressed: state.weekPlan == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            AppRoute.build(
                              context,
                              GroceryListScreen(
                                weekPlan: state.weekPlan!,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
            PopupMenuButton<_PlanAction>(
              tooltip: 'More options',
              onSelected: (action) {
                switch (action) {
                  case _PlanAction.reset:
                    _confirmPlanClear(context);
                  case _PlanAction.settings:
                    Navigator.push(
                      context,
                      AppRoute.build(context, const SettingsScreen()),
                    );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _PlanAction.reset,
                  child: ListTile(
                    leading: Icon(Icons.restart_alt),
                    title: Text('Reset week'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _PlanAction.settings,
                  child: ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<MealPlanCubit, MealPlanState>(
          builder: (context, state) {
            if (state.errorMessage != null && state.weekPlan == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<MealPlanCubit>().watchPlan(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.isLoading && state.weekPlan == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final weekPlan = state.weekPlan;
            if (weekPlan == null) {
              return const SizedBox.shrink();
            }

            if (AppBreakpoints.windowClass(context) == AppWindowClass.compact) {
              return ListView.builder(
                key: const PageStorageKey('phone-plan-list'),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: weekPlan.days.length,
                itemBuilder: (context, index) => _buildDay(
                  context,
                  weekPlan.days[index],
                  index,
                ),
              );
            }

            return SingleChildScrollView(
              key: const PageStorageKey('tablet-plan-list'),
              child: AppConstrainedContent(
                maxWidth: AppBreakpoints.wideContent,
                padding: EdgeInsets.fromLTRB(
                  AppBreakpoints.gutter(context),
                  8,
                  AppBreakpoints.gutter(context),
                  32,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1180
                        ? 3
                        : constraints.maxWidth >= 720
                            ? 2
                            : 1;
                    const spacing = 16.0;
                    final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 0,
                      children: [
                        for (var index = 0; index < weekPlan.days.length; index++)
                          SizedBox(
                            width: width,
                            child: _buildDay(
                              context,
                              weekPlan.days[index],
                              index,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Builds a responsive day card.
  Widget _buildDay(BuildContext context, DayPlan dayPlan, int index) {
    return AppEntrance(
      index: index,
      child: PlanDayItem(
        dayPlan: dayPlan,
        onEditDayPlanPressed: () => _showManageDaySheet(context, dayPlan.dayId),
      ),
    );
  }

  void _showManageDaySheet(BuildContext context, int dayId) {
    if (MediaQuery.sizeOf(context).width >= AppBreakpoints.medium) {
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            width: 720,
            height: (MediaQuery.sizeOf(context).height - 96).clamp(480, 760).toDouble(),
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ManageDaySheet(
                dayId: dayId,
                showCloseButton: true,
              ),
            ),
          ),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.84,
          child: ManageDaySheet(dayId: dayId),
        );
      },
    );
  }

  void _confirmPlanClear(BuildContext context) {
    MyUtils.showDeleteConfirmationDialog(
      context,
      'Reset Plans',
      'Are you sure you want to clear all plans?',
      'Reset',
      () {
        context.read<MealPlanCubit>().clearWeekPlan();
      },
    );
  }
}

enum _PlanAction { reset, settings }
