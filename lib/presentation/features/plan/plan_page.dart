import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/data/repositories/meal_plan_repository.dart';
import 'package:reciplan3/presentation/widgets/plan_day_item.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/presentation/features/settings/settings_screen.dart';
import 'package:reciplan3/logic/plan/meal_plan_cubit.dart';
import 'package:reciplan3/logic/plan/meal_plan_state.dart';
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
          backgroundColor: ReciplanCustomColors.appBarColor,
          foregroundColor: Colors.white,
          title: const Text('Reciplan'),
          actions: [
            IconButton(
              onPressed: () => _confirmPlanClear(context),
              icon: const Icon(Icons.clear_all),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings),
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

            return ListView.builder(
              itemCount: weekPlan.days.length,
              itemBuilder: (context, index) {
                final dayPlan = weekPlan.days[index];
                return PlanDayItem(
                  dayPlan: dayPlan,
                  onEditDayPlanPressed: () => _showManageDaySheet(context, dayPlan.dayId),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showManageDaySheet(BuildContext context, int dayId) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (context) {
        return ManageDaySheet(dayId: dayId);
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
